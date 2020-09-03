import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:restio/restio.dart' show HawkAlgorithm, RequestUri;
import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/data/entities/cookie_entity.dart';
import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/form_entity.dart';
import 'package:restler/data/entities/header_entity.dart';
import 'package:restler/data/entities/multipart_entity.dart';
import 'package:restler/data/entities/query_entity.dart';
import 'package:restler/data/entities/request_auth_entity.dart';
import 'package:restler/data/entities/request_body_entity.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/request_header_entity.dart';
import 'package:restler/data/entities/request_query_entity.dart';
import 'package:restler/data/entities/request_settings_entity.dart';
import 'package:restler/data/entities/variable_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/services/import_export.dart';
import 'package:yaml/yaml.dart';

class InsomniaImporter extends Importer {
  final _rawFolders = <String, Map<dynamic, dynamic>>{};
  final _workspaces = <String, WorkspaceEntity>{};
  final _environments = <String, EnvironmentEntity>{};
  final _folders = <String, FolderEntity>{};
  final WorkspaceEntity workspace;

  InsomniaImporter(this.workspace);

  @override
  ImportExportData importFromText(
    String text, {
    String fileType,
    String password,
  }) {
    fileType ??= 'json';

    switch (fileType.toLowerCase()) {
      case 'json':
        final o = json.decode(text);
        return importFromMap(o);
      case 'yaml':
        final o = loadYaml(text);
        return importFromMap(o);
      default:
        return null;
    }
  }

  @override
  ImportExportData importFromMap(Map o) {
    final format = o['__export_format'];

    if (format == null || format < 3) {
      throw const ImportException(
        "The Collection's version is not supported. Use version 3 or above.",
      );
    }

    final resources = o['resources'] as List;

    return importResources(resources);
  }

  ImportExportData importResources(List resources) {
    final folders = <FolderEntity>[];
    final requests = <CallEntity>[];
    final cookies = <CookieEntity>[];
    final variables = <VariableEntity>[];

    // Pega os workspaces primeiro!
    // Depois, pega as pastas!
    for (final resource in resources) {
      switch (resource['_type']) {
        case 'workspace':
          _workspaces[resource['_id']] = WorkspaceEntity(
            uid: generateUuid(),
            name: resource['name'],
          );
          break;
        case 'environment':
          final parentEnvironment = _environments[resource['parentId']];

          final workspace = parentEnvironment?.workspace ??
              _workspaces[resource['parentId']] ??
              this.workspace;

          // Se o pai é um workspace, então é um ambiente global.
          final environment = parentEnvironment == null
              ? EnvironmentEntity.none.copyWith(workspace: workspace)
              : EnvironmentEntity(
                  uid: generateUuid(),
                  name: resource['name'],
                  workspace: workspace,
                );

          variables.addAll(
            importEnvironmentVariables(resource['data'], environment),
          );

          _environments[resource['_id']] = environment;
          break;
        case 'request_group':
          _rawFolders[resource['_id']] = resource;
          break;
      }
    }

    for (final resource in resources) {
      if (resource is Map && resource['_type'] == 'request_group') {
        _importFolder(resource, folders);
      }
    }

    // Pega requisições e cookies.
    for (final resource in resources) {
      switch (resource['_type']) {
        case 'request':
          requests.add(importRequest(resource));
          break;
        case 'cookie_jar':
          cookies.addAll(importCookieJar(resource));
          break;
      }
    }

    return ImportExportData(
      cookies: cookies,
      folders: sortFolders(folders),
      requests: requests,
      workspaces: [
        for (final item in _workspaces.values) if (item.uid != null) item,
      ],
      environments: [
        for (final item in _environments.values) if (item.uid != null) item,
      ],
      variables: variables,
    );
  }

  List<VariableEntity> importEnvironmentVariables(
    Map data,
    EnvironmentEntity environment,
  ) {
    if (data != null) {
      final res = <String, String>{};

      buildEnvironmentVariables(null, data, res);

      return [
        for (final name in res.keys)
          VariableEntity(
            uid: generateUuid(),
            workspace: environment.workspace,
            environment: environment,
            name: name,
            value: res[name],
          ),
      ];
    }

    return const [];
  }

  void buildEnvironmentVariables(
    String parentName,
    Map input,
    Map<String, String> output,
  ) {
    for (final key in input.keys) {
      final item = input[key];

      if (item is Map) {
        buildEnvironmentVariables(key, item, output);
      } else if (item is bool || item is num || item is String) {
        final name = parentName == null ? key : '$parentName.$key';
        output[name] = item;
      }
    }
  }

  List<CookieEntity> importCookieJar(Map o) {
    final data = <CookieEntity>[];

    if (o == null) {
      return data;
    }

    final cookies = o['cookies'];
    final parentId = o['parentId'];

    if (cookies == null) {
      return data;
    }

    for (final c in cookies) {
      final timestamp = parseDateToInt(c['lastAccessed']);
      final String name = c['key'] ?? '';
      final String value = c['value'] ?? '';
      final expires = parseDateToDateTime(c['expires']);
      final int maxAge = c['maxAge'];
      final String path = c['path'] ?? '/';
      final String domain = c['domain'] ?? '';
      final bool secure = c['secure'] ?? false;
      final bool httpOnly = c['httpOnly'] ?? false;

      final cookie = CookieEntity(
        uid: generateUuid(),
        timestamp: timestamp,
        name: name,
        value: value,
        expires: expires,
        maxAge: maxAge,
        domain: domain,
        path: path.isEmpty ? '/' : path,
        secure: secure,
        httpOnly: httpOnly,
        workspace: _workspaces[parentId] ?? workspace,
      );

      data.add(cookie);
    }

    return data;
  }

  FolderEntity _importFolder(
    Map o,
    List<FolderEntity> folders,
  ) {
    final String id = o['_id'];
    final String name = o['name'];
    final String parent = o['parentId'];

    if (_folders.containsKey(id)) {
      return _folders[id];
    }
    // Seu pai é um workspace.
    else if (parent == insomniaWorkspaceId || _workspaces.containsKey(parent)) {
      final folder = FolderEntity(
        uid: generateUuid(),
        name: name,
        parent: FolderEntity.root,
        workspace: _workspaces[parent] ?? workspace,
      );

      _folders[id] = folder;

      folders.add(folder);

      return folder;
    }
    // Seu pai é uma pasta e já foi encontrado.
    else if (_folders.containsKey(parent)) {
      final folder = FolderEntity(
        uid: generateUuid(),
        name: name,
        parent: _folders[parent],
        workspace: _folders[parent].workspace,
      );

      _folders[id] = folder;

      folders.add(folder);

      return folder;
    }
    // Tem pai mas ainda não foi encontrado.
    else {
      final parentFolder = _importFolder(_rawFolders[parent], folders);

      final folder = FolderEntity(
        uid: generateUuid(),
        name: name,
        parent: parentFolder,
        workspace: parentFolder.workspace,
      );

      _folders[id] = folder;

      folders.add(folder);

      return folder;
    }
  }

  CallEntity importRequest(Map o) {
    final String name = o['name'];
    final String method = o['method'];
    final String url = o['url'];
    RequestUri uri;

    try {
      if (url.contains('://')) {
        uri = RequestUri.parse(url);
      } else {
        uri = RequestUri.parse('http://$url');
      }
    } catch (e) {
      rethrow;
    }

    final requestBody = importRequestBody(o['body']);
    final requestQuery = importRequestQuery(uri, o['parameters']);
    final requestHeader = importRequestHeader(o['headers']);
    final requestAuth = importRequestAuth(o['authentication']);
    final description = o['description'];
    final parentId = o['parentId'];
    final sendCookies = o['settingSendCookies'] ?? true;
    final storeCookies = o['settingStoreCookies'] ?? true;

    final settings = RequestSettingsEntity(
      sendCookies: sendCookies,
      storeCookies: storeCookies,
    );

    final scheme = uri.scheme?.toLowerCase();

    final request = RequestEntity(
      uid: generateUuid(),
      scheme: scheme == 'http' || scheme == 'https' ? scheme : 'auto',
      method: method,
      url: uri.toUriString(),
      body: requestBody,
      query: requestQuery,
      header: requestHeader,
      auth: requestAuth,
      description: description ?? '',
      settings: settings,
    );

    final workspace = _folders[parentId]?.workspace ??
        _workspaces[parentId] ??
        WorkspaceEntity.empty;

    final call = CallEntity(
      uid: generateUuid(),
      name: name,
      folder: _folders[parentId] ?? FolderEntity.root,
      request: request,
      workspace: workspace,
    );

    return call;
  }

  RequestBodyEntity importRequestBody(Map o) {
    if (o == null) {
      return RequestBodyEntity.empty;
    }
    // Text.
    if (o['text'] != null) {
      return RequestBodyEntity.text(o['text']);
    }
    // File.
    if (o['fileName'] != null) {
      return RequestBodyEntity.file(o['fileName']);
    }
    // Multipart.
    if (o['mimeType'] == 'multipart/form-data') {
      final items = <MultipartEntity>[];
      final params = o['params'] as List;

      for (final item in params) {
        // File.
        if (item['type'] == 'file') {
          final String filePath = item['fileName']?.replaceAll('\\', '/') ?? '';
          final fileName = filePath.isNotEmpty ? path.basename(filePath) : '';

          items.add(
            MultipartEntity.file(
              generateUuid(),
              item['name'],
              filePath,
              fileName,
              enabled: isEnabled(item['disabled']),
            ),
          );
        }
        // Text.
        else {
          items.add(
            MultipartEntity.text(
              generateUuid(),
              item['name'],
              item['value'],
              enabled: isEnabled(item['disabled']),
            ),
          );
        }
      }

      return RequestBodyEntity.multipart(items);
    }
    // Form.
    if (o['mimeType'] == 'application/x-www-form-urlencoded') {
      final params = o['params'] as List;

      final items = <FormEntity>[
        for (final item in params)
          FormEntity(
            uid: generateUuid(),
            name: item['name'],
            value: item['value'],
            enabled: isEnabled(item['disabled']),
          ),
      ];

      return RequestBodyEntity.form(items);
    }
    // None.
    return RequestBodyEntity.empty;
  }

  RequestQueryEntity importRequestQuery(
    RequestUri uri,
    List queries,
  ) {
    final res = <QueryEntity>[];

    uri.queries.forEach((item) {
      res.add(
        QueryEntity(
          uid: generateUuid(),
          name: item.name,
          value: item.value,
        ),
      );
    });

    if (queries != null) {
      for (final item in queries) {
        res.add(
          QueryEntity(
            uid: generateUuid(),
            name: item['name'],
            value: item['value'],
            enabled: isEnabled(item['disabled']),
          ),
        );
      }
    }

    return RequestQueryEntity(queries: res);
  }

  RequestHeaderEntity importRequestHeader(List headers) {
    final items = <HeaderEntity>[
      for (final header in headers ?? const [])
        HeaderEntity(
          uid: generateUuid(),
          name: header['name'],
          value: header['value'],
          enabled: isEnabled(header['disabled']),
        ),
    ];

    return RequestHeaderEntity(headers: items);
  }

  RequestAuthEntity importRequestAuth(Map o) {
    if (o == null) {
      return RequestAuthEntity.empty;
    }
    // Basic Auth.
    if (o['type'] == 'basic') {
      return RequestAuthEntity.basic(
        o['username'],
        o['password'],
        enabled: isEnabled(o['disabled']),
      );
    }
    // Bearer Token.
    else if (o['type'] == 'bearer') {
      return RequestAuthEntity.bearer(
        o['token'],
        prefix: o['prefix'],
        enabled: isEnabled(o['disabled']),
      );
    }
    // Hawk.
    else if (o['type'] == 'hawk') {
      final algorithm = o['algorithm'] == 'sha256'
          ? HawkAlgorithm.sha256
          : HawkAlgorithm.sha1;
      return RequestAuthEntity.hawk(
        o['id'],
        o['key'],
        ext: o['ext'],
        algorithm: algorithm,
        enabled: isEnabled(o['disabled']),
      );
    }
    // Digest Auth.
    else if (o['type'] == 'digest') {
      return RequestAuthEntity.digest(
        o['username'],
        o['password'],
        enabled: isEnabled(o['disabled']),
      );
    }
    // None.
    else {
      return RequestAuthEntity.empty;
    }
  }

  static bool isEnabled(o) {
    return o == null || o != true;
  }
}
