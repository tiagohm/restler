import 'dart:convert';

import 'package:restio/restio.dart';
import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/multipart_entity.dart';
import 'package:restler/data/entities/request_auth_entity.dart';
import 'package:restler/data/entities/request_body_entity.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/request_header_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/services/import_export.dart';

class PostmanExporter extends Exporter {
  final JsonEncoder json;
  final String postmanId;

  PostmanExporter({
    JsonEncoder json,
    this.postmanId,
  }) : json = json ?? const JsonEncoder();

  @override
  String export(
    ImportExportData data, {
    String fileType,
    String password,
    String name,
  }) {
    return json.convert(exportFromData(data, name));
  }

  Map<dynamic, dynamic> exportFromData(
    ImportExportData data,
    String name,
  ) {
    return {
      'info': {
        '_postman_id': postmanId ?? generateUuid(),
        'name': name == null || name.isEmpty ? 'Restler' : name,
        'schema': postmanSchema210,
      },
      'item': exportItem(FolderEntity.root, data.folders, data.requests),
    };
  }

  List exportItem(
    FolderEntity parent,
    List<FolderEntity> folders,
    List<CallEntity> calls,
  ) {
    return [
      // Percorrer pastas e chamadas na qual está dentro de sua pasta-pai.
      for (final folder in folders)
        if (folder.parent == parent)
          {
            'name': folder.name,
            'item': exportItem(folder, folders, calls),
          },
      for (final call in calls)
        if (call.folder == parent)
          {
            'name': call.name,
            'request': {
              'auth': exportRequestAuth(call.request.auth),
              'method': call.request.method,
              'header': exportRequestHeader(call.request.header),
              'body': exportRequestBody(call.request.body),
              'url': exportRequestUrl(call.request),
            },
          },
    ];
  }

  Map exportRequestUrl(RequestEntity request) {
    final url = request.rightUrl;
    final uri = RequestUri.parse(url);

    return {
      'raw': url,
      if (uri.scheme != null) 'protocol': uri.scheme,
      if (uri.host != null) 'host': uri.host.split('.'),
      if (uri.hasAuthority)
        'auth': {
          'user': uri.username,
          if (uri.password != null) 'password': uri.password,
        },
      if (uri.port != null) 'port': '${uri.port}',
      'path': uri.paths,
      'query': [
        for (final item in request.query.queries)
          {
            'key': item.name,
            'value': item.value,
            'disabled': !request.query.enabled || !item.enabled,
          },
      ],
    };
  }

  List exportRequestHeader(RequestHeaderEntity header) {
    return [
      for (final item in header.headers)
        {
          'key': item.name,
          'value': item.value,
          'type': 'text',
          'disabled': !header.enabled || !item.enabled,
        },
    ];
  }

  Map exportRequestAuth(RequestAuthEntity auth) {
    if (!auth.enabled || auth.type == RequestAuthType.none) {
      return {
        'type': 'noauth',
      };
    } else if (auth.type == RequestAuthType.basic) {
      return {
        'type': 'basic',
        'basic': [
          {'key': 'password', 'value': auth.basicPassword, 'type': 'string'},
          {'key': 'username', 'value': auth.basicUsername, 'type': 'string'},
        ],
      };
    } else if (auth.type == RequestAuthType.digest) {
      return {
        'type': 'digest',
        'digest': [
          {'key': 'password', 'value': auth.digestPassword, 'type': 'string'},
          {'key': 'username', 'value': auth.digestUsername, 'type': 'string'},
        ],
      };
    } else if (auth.type == RequestAuthType.bearer) {
      if (auth.bearerPrefix == 'Bearer') {
        return {
          'type': 'bearer',
          'bearer': [
            {'key': 'token', 'value': auth.bearerToken, 'type': 'string'},
          ],
        };
      } else {
        return {
          'type': 'apikey',
          'apikey': [
            {'key': 'key', 'value': auth.bearerPrefix, 'type': 'string'},
            {'key': 'value', 'value': auth.bearerToken, 'type': 'string'},
            {'key': 'in', 'value': 'header', 'type': 'string'},
          ],
        };
      }
    } else if (auth.type == RequestAuthType.hawk) {
      final algorithm =
          auth.hawkAlgorithm == HawkAlgorithm.sha1 ? 'sha1' : 'sha256';

      return {
        'type': 'hawk',
        'hawk': [
          {'key': 'authKey', 'value': auth.hawkKey, 'type': 'string'},
          {'key': 'algorithm', 'value': algorithm, 'type': 'string'},
          {'key': 'authId', 'value': auth.hawkId, 'type': 'string'},
          {'key': 'extraData', 'value': auth.hawkExt, 'type': 'string'},
        ],
      };
    } else {
      return null;
    }
  }

  Map exportRequestBody(RequestBodyEntity body) {
    if (body.type == RequestBodyType.none) {
      return null;
    } else if (body.type == RequestBodyType.form) {
      return {
        'type': 'urlencoded',
        'urlencoded': [
          for (final item in body.formItems)
            {
              'key': item.name,
              'value': item.value,
              'type': 'text',
              'disabled': !body.enabled || !item.enabled,
            },
        ],
      };
    } else if (body.type == RequestBodyType.multipart) {
      return {
        'type': 'formdata',
        'formdata': [
          for (final item in body.multipartItems)
            if (item.type == MultipartType.text)
              {
                'key': item.name,
                'value': item.value,
                'type': 'text',
                'disabled': !body.enabled || !item.enabled,
              }
            else
              {
                'key': item.name,
                'src': item.file.path,
                'type': 'file',
                'disabled': !body.enabled || !item.enabled,
              },
        ],
      };
    } else if (body.type == RequestBodyType.text) {
      return {
        'type': 'raw',
        'raw': body.text,
      };
    } else if (body.type == RequestBodyType.file) {
      return {
        'mode': 'file',
        'file': {
          'src': body.file,
        },
      };
    } else {
      return null;
    }
  }
}
