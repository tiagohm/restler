import 'dart:convert';

import 'package:restio/restio.dart' show HawkAlgorithm;
import 'package:restler/constants.dart';
import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/data/entities/cookie_entity.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/multipart_entity.dart';
import 'package:restler/data/entities/request_auth_entity.dart';
import 'package:restler/data/entities/request_body_entity.dart';
import 'package:restler/data/entities/request_header_entity.dart';
import 'package:restler/data/entities/request_query_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/services/import_export.dart';

class InsomniaExporter extends Exporter {
  @override
  String export(
    ImportExportData data, {
    String fileType,
    String password,
    String name,
  }) {
    fileType ??= 'json';

    switch (fileType.toLowerCase()) {
      case 'json':
        return json.encode(exportFromData(data));
      default:
        return null;
    }
  }

  Map<dynamic, dynamic> exportFromData(ImportExportData data) {
    return {
      '_type': 'export',
      '__export_format': 4,
      '__export_date': currentUtc().toIso8601String(),
      '__export_source': 'br.tiagohm.restler:v$appVersion',
      'resources': exportResources(data),
    };
  }

  List exportResources(ImportExportData data) {
    return [
      ...exportWorkspaces(data.workspaces ?? const []),
      ...exportFolders(data.folders ?? const []),
      ...exportRequests(data.requests ?? const []),
      ...exportCookies(data.cookies ?? const []),
    ];
  }

  List exportWorkspaces(List<WorkspaceEntity> workspaces) {
    return [for (final workspace in workspaces) exportWorkspace(workspace)];
  }

  List exportFolders(List<FolderEntity> folders) {
    return [for (final folder in folders) exportFolder(folder)];
  }

  List exportRequests(List<CallEntity> calls) {
    return [for (final call in calls) exportCall(call)];
  }

  Map<dynamic, dynamic> exportWorkspace(WorkspaceEntity workspace) {
    return {
      '_id': workspace.uid,
      'created': currentMillis(),
      'description': '',
      'modified': currentMillis(),
      'name': workspace.name,
      'parentId': null,
      '_type': 'workspace',
    };
  }

  Map<dynamic, dynamic> exportFolder(FolderEntity folder) {
    return {
      '_id': folder.uid,
      'created': currentMillis(),
      'description': '',
      'environment': {},
      'modified': currentMillis(),
      'name': folder.name,
      'parentId':
          folder.parent?.uid ?? folder.workspace?.uid ?? insomniaWorkspaceId,
      '_type': 'request_group'
    };
  }

  Map<dynamic, dynamic> exportCall(CallEntity call) {
    return {
      '_id': call.uid,
      'authentication': exportRequestAuth(call.request.auth),
      'body': exportRequestBody(call.request.body),
      'created': currentMillis(),
      'description': '',
      'headers': exportRequestHeader(call.request.header),
      'method': call.request.method,
      'modified': currentMillis(),
      'name': call.name,
      'parameters': exportRequestQuery(call.request.query),
      'parentId':
          call.folder?.uid ?? call.workspace?.uid ?? insomniaWorkspaceId,
      'settingDisableRenderRequestBody': false,
      'settingEncodeUrl': true,
      'settingRebuildPath': true,
      'settingSendCookies': call.request.settings.sendCookies,
      'settingStoreCookies': call.request.settings.storeCookies,
      'url': call.request.rightUrl,
      '_type': 'request'
    };
  }

  Map<dynamic, dynamic> exportRequestAuth(RequestAuthEntity auth) {
    return {
      if (auth.type == RequestAuthType.basic) ...{
        'disabled': !auth.enabled,
        'password': auth.basicPassword,
        'username': auth.basicUsername,
        'type': 'basic',
      } else if (auth.type == RequestAuthType.bearer) ...{
        'disabled': !auth.enabled,
        'prefix': auth.bearerPrefix,
        'token': auth.bearerToken,
        'type': 'bearer',
      } else if (auth.type == RequestAuthType.digest) ...{
        'disabled': !auth.enabled,
        'password': auth.digestPassword,
        'username': auth.digestUsername,
        'type': 'digest',
      } else if (auth.type == RequestAuthType.hawk) ...{
        'algorithm':
            auth.hawkAlgorithm == HawkAlgorithm.sha256 ? 'sha256' : 'sha1',
        'ext': auth.hawkExt,
        'id': auth.hawkId,
        'key': auth.hawkKey,
        'type': 'hawk',
      }
    };
  }

  Map<dynamic, dynamic> exportRequestBody(RequestBodyEntity body) {
    return {
      if (body.type == RequestBodyType.multipart)
        ...exportRequestBodyMultipart(body)
      else if (body.type == RequestBodyType.form)
        ...exportRequestBodyForm(body)
      else if (body.type == RequestBodyType.file)
        ...exportRequestBodyFile(body)
      else if (body.type == RequestBodyType.text)
        ...exportRequestBodyText(body)
    };
  }

  Map<dynamic, dynamic> exportRequestBodyMultipart(RequestBodyEntity body) {
    return {
      'mimeType': 'multipart/form-data',
      'params': [
        for (final item in body.multipartItems)
          {
            if (item.type == MultipartType.file) ...{
              'type': 'file',
              'fileName': item.file?.path,
            },
            'disabled': !item.enabled,
            'id': item.uid,
            'name': item.name,
            'value': item.value
          },
      ],
    };
  }

  Map<dynamic, dynamic> exportRequestBodyForm(RequestBodyEntity body) {
    return {
      'mimeType': 'application/x-www-form-urlencoded',
      'params': [
        for (final item in body.formItems)
          {
            'disabled': !item.enabled,
            'id': item.uid,
            'name': item.name,
            'value': item.value
          },
      ],
    };
  }

  Map<dynamic, dynamic> exportRequestBodyFile(RequestBodyEntity body) {
    return {
      'fileName': body.file ?? '',
      'mimeType': 'application/octet-stream',
    };
  }

  Map<dynamic, dynamic> exportRequestBodyText(RequestBodyEntity body) {
    return {
      'text': body.text ?? '',
      'mimeType': 'text/plain',
    };
  }

  List exportRequestHeader(RequestHeaderEntity header) {
    return [
      for (final h in header.headers)
        {
          'id': h.uid,
          'name': h.name,
          'value': h.value,
          'disabled': !header.enabled || !h.enabled,
        },
    ];
  }

  List exportRequestQuery(RequestQueryEntity query) {
    return [
      for (final q in query.queries)
        {
          'id': q.uid,
          'name': q.name,
          'value': q.value,
          'disabled': !query.enabled || !q.enabled,
        },
    ];
  }

  List exportCookies(List<CookieEntity> cookies) {
    final cookiesByWorkspace = <WorkspaceEntity, List<CookieEntity>>{};

    for (final item in cookies) {
      if (!cookiesByWorkspace.containsKey(item.workspace)) {
        cookiesByWorkspace[item.workspace] = [];
      }

      cookiesByWorkspace[item.workspace].add(item);
    }

    final jars = List.of(cookiesByWorkspace.keys);

    return [
      for (var i = 0; i < jars.length; i++)
        {
          '_id': '__COOKIEJAR_${i}__',
          'cookies': [
            for (final cookie in cookiesByWorkspace[jars[i]])
              {
                'creation': currentUtc().toIso8601String(),
                'domain': cookie.domain,
                'hostOnly': true,
                'httpOnly': cookie.httpOnly,
                'id': cookie.uid,
                'key': cookie.name,
                'lastAccessed':
                    parseDateToDateTime(cookie.timestamp).toIso8601String(),
                'path': cookie.path,
                'secure': cookie.secure,
                'value': cookie.value,
              },
          ],
          'created': currentMillis(),
          'modified': currentMillis(),
          'name': 'Jar $i',
          'parentId': jars[i].uid,
          '_type': 'cookie_jar'
        },
    ];
  }
}
