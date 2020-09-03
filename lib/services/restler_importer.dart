import 'dart:convert';

import 'package:restler/crypto.dart';
import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/data/entities/cookie_entity.dart';
import 'package:restler/data/entities/dns_entity.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/proxy_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/services/import_export.dart';

class RestlerImporter extends Importer {
  @override
  ImportExportData importFromText(
    String text, {
    String fileType,
    String password,
  }) {
    final decoded = json.decode(text);
    final encrypted = decoded['encrypted'] == true;

    if (encrypted && !isEncrypted(password)) {
      throw const ImportException('Password must be provided.');
    }

    if (encrypted) {
      final decodedData = json.decode(decrypt(decoded['data'], password));
      return importFromMap(decodedData);
    } else {
      final decodedData = decoded['data'];
      return importFromMap(decodedData);
    }
  }

  bool isEncrypted(String password) {
    return password != null && password.trim().isNotEmpty;
  }

  @override
  ImportExportData importFromMap(Map o) {
    return ImportExportData(
      workspaces: o['workspaces'] == null
          ? const []
          : (o['workspaces'] as List)
              .map((item) => WorkspaceEntity.fromJson(item))
              .toList(),
      folders: o['folders'] == null
          ? const []
          : sortFolders(
              (o['folders'] as List)
                  .map((item) => FolderEntity.fromJson(item))
                  .toList(),
            ),
      requests: o['requests'] == null
          ? const []
          : (o['requests'] as List)
              .map((item) => CallEntity.fromJson(item))
              .toList(),
      cookies: o['cookies'] == null
          ? const []
          : (o['cookies'] as List)
              .map((item) => CookieEntity.fromJson(item))
              .toList(),
      proxies: o['proxies'] == null
          ? const []
          : (o['proxies'] as List)
              .map((item) => ProxyEntity.fromJson(item))
              .toList(),
      dns: o['dns'] == null
          ? const []
          : (o['dns'] as List).map((item) => DnsEntity.fromJson(item)).toList(),
    );
  }
}
