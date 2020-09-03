import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:restio/restio.dart' show HawkAlgorithm, RequestUri;
import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/form_entity.dart';
import 'package:restler/data/entities/header_entity.dart';
import 'package:restler/data/entities/multipart_entity.dart';
import 'package:restler/data/entities/multipart_file_entity.dart';
import 'package:restler/data/entities/query_entity.dart';
import 'package:restler/data/entities/request_auth_entity.dart';
import 'package:restler/data/entities/request_body_entity.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/request_header_entity.dart';
import 'package:restler/data/entities/request_query_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/services/import_export.dart';

class PostmanImporter extends Importer {
  final WorkspaceEntity workspace;
  final bool createRootFolder;

  PostmanImporter(
    this.workspace, {
    this.createRootFolder = true,
  });

  @override
  ImportExportData importFromText(
    String text, {
    String fileType,
    String password,
  }) {
    final o = json.decode(text);
    return importFromMap(o);
  }

  @override
  ImportExportData importFromMap(Map o) {
    final info = o['info'];

    if (info != null && info['schema'] == postmanSchema210) {
      final name = info['name'];

      final auth = importRequestAuth(o['auth']) ?? RequestAuthEntity.empty;

      // A coleção será uma pasta.
      final root = createRootFolder
          ? FolderEntity(
              uid: generateUuid(),
              name: name,
              parent: FolderEntity.root,
            )
          : FolderEntity.root;

      final folders = <FolderEntity>[];
      final calls = <CallEntity>[];
      final items = importItems(root, auth, o['item']);

      if (root != FolderEntity.root) {
        folders.add(root);
      }

      for (final item in items) {
        if (item is FolderEntity) {
          folders.add(item);
        } else if (item is CallEntity) {
          calls.add(item);
        }
      }

      return ImportExportData(
        folders: folders,
        requests: calls,
        // cookies: const [], // Postman não suporta importação de cookies?
      );
    } else {
      throw const ImportException(
        "The Collection's version is not supported. Use version 2.1.0 or above.",
      );
    }
  }

  /// Retorna uma lista contendo pastas ou chamadas.
  List importItems(
    FolderEntity parent,
    RequestAuthEntity auth,
    List items,
  ) {
    return [
      for (final item in items) ...importItem(parent, auth, item),
    ];
  }

  /// Retorna uma lista contendo pastas ou chamadas dentro de uma pasta.
  List importItem(
    FolderEntity parent,
    RequestAuthEntity auth,
    Map o,
  ) {
    // É uma chamada.
    if (o['request'] != null) {
      return [importCall(o['name'], parent, auth, o['request'])];
    }

    // É uma pasta.

    final folder = FolderEntity(
      uid: generateUuid(),
      name: o['name'],
      parent: parent,
      workspace: workspace,
    );

    return [
      folder,
      for (final item in o['item']) ...importItem(folder, auth, item),
    ];
  }

  CallEntity importCall(
    String name,
    FolderEntity parent,
    RequestAuthEntity auth,
    Map o,
  ) {
    return CallEntity(
      uid: generateUuid(),
      folder: parent,
      name: name,
      request: importRequest(o, auth),
      workspace: workspace,
    );
  }

  RequestEntity importRequest(
    Map o,
    RequestAuthEntity auth,
  ) {
    final method = o['method'] ?? 'GET';
    final uri = importUri(o['url']); // Sem Queries.
    final description = o['description'];
    final body = importRequestBody(o['body']);
    final header = importRequestHeader(o['header'], o['body']);
    final scheme = uri.scheme?.toLowerCase();

    return RequestEntity(
      uid: generateUuid(),
      method: method,
      scheme: scheme == 'http' || scheme == 'https' ? scheme : 'auto',
      url: uri.toUriString(),
      query: o['url'] == null
          ? RequestQueryEntity.empty
          : importRequestQuery(o['url']['query'], o['auth']),
      header: header,
      auth: importRequestAuth(o['auth']) ?? auth,
      body: body,
      description: description ?? '',
    );
  }

  // A importação da URI ignora as queries.
  RequestUri importUri(Map o) {
    String username;
    String password;

    if (o['auth'] != null) {
      username = o['auth']['user'];
      password = o['auth']['password'];
    }

    final scheme = o['protocol'];

    final pathSegments = <String>[];
    final path = o['path'];

    final raw = o['raw'] as String ?? '';

    if (path is String) {
      pathSegments.add(path);
    } else if (path is List) {
      pathSegments.addAll(path.map((item) => item?.toString()));
    }

    return RequestUri(
      scheme: raw.contains('://') ? scheme : 'http',
      host: o['host']?.join('.') ?? '',
      username: username,
      password: password,
      paths: pathSegments,
      port: o['port'],
    );
  }

  RequestQueryEntity importRequestQuery(
    List queries,
    Map auth,
  ) {
    final res = <QueryEntity>[];

    if (auth != null && auth['type'] == 'apikey') {
      var isInQuery = false;
      var name = '';
      var value = '';

      for (final item in auth['apikey']) {
        switch (item['key']) {
          case 'in':
            isInQuery = item['value'] == 'query';
            break;
          case 'key':
            name = item['value'];
            break;
          case 'value':
            value = item['value'];
            break;
        }
      }

      if (isInQuery) {
        res.add(
          QueryEntity(
            uid: generateUuid(),
            name: name,
            value: value ?? '',
          ),
        );
      }
    }

    if (queries != null && queries.isNotEmpty) {
      for (final item in queries) {
        res.add(
          QueryEntity(
            uid: generateUuid(),
            enabled: isEnabled(item['disabled']),
            name: item['key'],
            value: item['value'] ?? '',
          ),
        );
      }
    }

    return RequestQueryEntity(queries: res);
  }

  RequestHeaderEntity importRequestHeader(
    List o,
    Map body,
  ) {
    final headers = <HeaderEntity>[];
    var hasContentType = false;

    if (o != null && o.isNotEmpty) {
      for (final item in o) {
        final name = item['key'] as String;

        if (name?.toLowerCase() == 'content-type') {
          hasContentType = true;
        }

        headers.add(HeaderEntity(
          uid: generateUuid(),
          enabled: isEnabled(item['disabled']),
          name: name,
          value: item['value'] ?? '',
        ));
      }
    }

    // Adiciona o Content-Type automaticamente a partir do Body.
    if (!hasContentType && body != null && body['mode'] == 'raw') {
      String value;

      if (body['options'] != null &&
          body['options']['raw'] != null &&
          body['options']['raw']['language'] != null) {
        final language = body['options']['raw']['language'];

        switch (language) {
          case 'xml':
            value = 'application/xml';
            break;
          case 'json':
            value = 'application/json';
            break;
            break;
          case 'javascript':
            value = 'text/javascript';
            break;
          case 'html':
            value = 'text/html';
            break;
        }
      }

      headers.insert(
          0,
          HeaderEntity(
            uid: generateUuid(),
            name: 'content-type',
            value: value ?? 'text/plain',
          ));
    }

    return headers.isEmpty
        ? RequestHeaderEntity.empty
        : RequestHeaderEntity(headers: headers);
  }

  RequestAuthEntity importRequestAuth(Map auth) {
    // Herda.
    if (auth == null || auth['type'] == null) {
      return null;
    }
    // Nenhum método de autenticação.
    if (auth['type'] == 'noauth') {
      return RequestAuthEntity.empty;
    }
    // Métodos.
    switch (auth['type']) {
      // Bearer Token.
      case 'bearer':
        var token = '';

        for (final item in auth['bearer']) {
          if (item['key'] == 'token') {
            token = item['value'];
          }
        }

        return RequestAuthEntity(
          type: RequestAuthType.bearer,
          enabled: true,
          bearerToken: token,
        );
      // Basic.
      case 'basic':
        var username = '';
        var password = '';

        for (final item in auth['basic']) {
          if (item['key'] == 'password') {
            password = item['value'];
          } else if (item['key'] == 'username') {
            username = item['value'];
          }
        }

        return RequestAuthEntity(
          type: RequestAuthType.basic,
          enabled: true,
          basicUsername: username,
          basicPassword: password,
        );
      // Digest.
      case 'digest':
        var username = '';
        var password = '';

        for (final item in auth['digest']) {
          if (item['key'] == 'password') {
            password = item['value'];
          } else if (item['key'] == 'username') {
            username = item['value'];
          }
        }

        return RequestAuthEntity(
          type: RequestAuthType.digest,
          enabled: true,
          digestUsername: username,
          digestPassword: password,
        );
      // Hawk.
      case 'hawk':
        var algorithm = HawkAlgorithm.sha256;
        var authKey = '';
        var authId = '';
        var extraData = '';

        for (final item in auth['hawk']) {
          if (item['key'] == 'authKey') {
            authKey = item['value'];
          } else if (item['key'] == 'algorithm' && item['value'] == 'sha1') {
            algorithm = HawkAlgorithm.sha1;
          } else if (item['key'] == 'authId') {
            authId = item['value'];
          } else if (item['key'] == 'extraData') {
            extraData = item['value'];
          }
        }

        return RequestAuthEntity(
          type: RequestAuthType.hawk,
          enabled: true,
          hawkAlgorithm: algorithm,
          hawkExt: extraData,
          hawkId: authId,
          hawkKey: authKey,
        );
      // API KEY.
      case 'apikey':
        var prefix = '';
        var token = '';
        var inHeader = true;

        for (final item in auth['apikey']) {
          if (item['key'] == 'key') {
            prefix = item['value'];
          } else if (item['key'] == 'value') {
            token = item['value'];
          } else if (item['key'] == 'in') {
            inHeader = item['value'] == 'header';
          }
        }

        if (!inHeader) {
          return RequestAuthEntity.empty;
        }

        return RequestAuthEntity(
          type: RequestAuthType.bearer,
          enabled: true,
          bearerToken: token,
          bearerPrefix: prefix,
        );
      default:
        return RequestAuthEntity.empty;
    }
  }

  RequestBodyEntity importRequestBody(Map o) {
    if (o == null) {
      return RequestBodyEntity.empty;
    }

    switch (o['mode']) {
      // File.
      case 'file':
        return o['file'] == null ||
                o['file'] is! Map ||
                o['file']['src'] == null
            ? const RequestBodyEntity.file('')
            : RequestBodyEntity.file(o['file']['src']);
      // Text.
      case 'raw':
        return RequestBodyEntity.text(o['raw']);
      // Form.
      case 'urlencoded':
        return RequestBodyEntity.form([
          for (final item in o['urlencoded'])
            FormEntity(
              uid: generateUuid(),
              enabled: isEnabled(item['disabled']),
              name: item['key'],
              value: item['value'],
            ),
        ]);
      // Multipart.
      case 'formdata':
        return RequestBodyEntity.multipart([
          for (final item in o['formdata'])
            // File.
            if (item['type'] == 'file')
              if (item['src'] is List)
                if (item['src'].isEmpty)
                  MultipartEntity(
                    type: MultipartType.file,
                    uid: generateUuid(),
                    enabled: isEnabled(item['disabled']),
                    name: item['key'],
                  )
                else
                  for (final file in item['src'])
                    MultipartEntity(
                      type: MultipartType.file,
                      uid: generateUuid(),
                      enabled: isEnabled(item['disabled']),
                      name: item['key'],
                      file: MultipartFileEntity(
                        name: path.basename(file),
                        path: file,
                      ),
                    )
              else
                MultipartEntity(
                  type: MultipartType.file,
                  uid: generateUuid(),
                  enabled: isEnabled(item['disabled']),
                  name: item['key'],
                  file: MultipartFileEntity(
                    name: path.basename(item['src']),
                    path: item['src'],
                  ),
                )
            // Text.
            else
              MultipartEntity(
                uid: generateUuid(),
                enabled: isEnabled(item['disabled']),
                name: item['key'],
                value: item['value'],
              ),
        ]);
      default:
        return RequestBodyEntity.empty;
    }
  }

  static bool isEnabled(o) {
    return o == null || o != true;
  }
}
