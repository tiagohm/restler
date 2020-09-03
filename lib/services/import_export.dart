import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/data/entities/cookie_entity.dart';
import 'package:restler/data/entities/dns_entity.dart';
import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/proxy_entity.dart';
import 'package:restler/data/entities/variable_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/services/insomnia_exporter.dart';
import 'package:restler/services/insomnia_importer.dart';
import 'package:restler/services/postman_exporter.dart';
import 'package:restler/services/postman_importer.dart';
import 'package:restler/services/restler_exporter.dart';
import 'package:restler/services/restler_importer.dart';

const insomniaWorkspaceId = '__WORKSPACE_ID__';

// const postmanSchema200 =
//     'https://schema.getpostman.com/json/collection/v2.0.0/collection.json';
const postmanSchema210 =
    'https://schema.getpostman.com/json/collection/v2.1.0/collection.json';

class ImportException implements Exception {
  final String message;

  const ImportException(this.message);
}

class ExportException implements Exception {
  final String message;

  const ExportException(this.message);
}

class ImportExportData extends Equatable {
  final List<FolderEntity> folders;
  final List<CallEntity> requests;
  final List<CookieEntity> cookies;
  final List<ProxyEntity> proxies;
  final List<WorkspaceEntity> workspaces;
  final List<DnsEntity> dns;
  final List<EnvironmentEntity> environments;
  final List<VariableEntity> variables;

  const ImportExportData({
    this.folders = const [],
    this.requests = const [],
    this.cookies = const [],
    this.proxies = const [],
    this.workspaces = const [],
    this.dns = const [],
    this.environments = const [],
    this.variables = const [],
  });

  @override
  List<Object> get props => [
        folders,
        requests,
        cookies,
        proxies,
        workspaces,
        dns,
        environments,
        variables,
      ];

  @override
  String toString() {
    return 'ImportExportData { folders: $folders, requests: $requests,'
        ' cookies: $cookies, proxies: $proxies, workspaces: $workspaces,'
        ' dns: $dns, environments: $environments, variables: $variables }';
  }
}

// Import.

abstract class Importer {
  Importer();

  factory Importer.insomnia(WorkspaceEntity workspace) {
    return InsomniaImporter(workspace);
  }

  factory Importer.restler() {
    return RestlerImporter();
  }

  factory Importer.postman(
    WorkspaceEntity workspace, {
    bool createRootFolder = true,
  }) {
    return PostmanImporter(workspace, createRootFolder: createRootFolder);
  }

  ImportExportData import(
    List<int> data, {
    String fileType,
    String password,
  }) {
    final text = utf8.decode(data);

    return importFromText(
      text,
      fileType: fileType,
      password: password,
    );
  }

  ImportExportData importFromText(
    String text, {
    String fileType,
    String password,
  });

  ImportExportData importFromMap(Map o);
}

abstract class Exporter {
  Exporter();

  factory Exporter.insomnia() {
    return InsomniaExporter();
  }

  factory Exporter.restler() {
    return RestlerExporter();
  }

  factory Exporter.postman({
    JsonEncoder json,
    String postmanId,
  }) {
    return PostmanExporter(
      json: json,
      postmanId: postmanId,
    );
  }

  String export(
    ImportExportData data, {
    String fileType,
    String password,
    String name,
  });
}

int parseDateToInt(date) {
  if (date == null) return null;
  if (date is int) return date;
  if (date is String) return DateTime.tryParse(date)?.millisecondsSinceEpoch;
  return null;
}

DateTime parseDateToDateTime(date) {
  if (date == null) return null;
  if (date is int) {
    return DateTime.fromMillisecondsSinceEpoch(date, isUtc: true);
  }
  if (date is String) return DateTime.tryParse(date);
  return null;
}

List<FolderEntity> sortFolders(List<FolderEntity> folders) {
  final sortedFolders = List.of(folders);

  sortedFolders.sort((a, b) {
    // Pasta-raiz vem em primeiro.
    if (a.insideRoot) return -1;
    if (b.insideRoot) return 1;
    // Pasta-pai vem em seguida.
    if (b.isSubFolder(a)) return -1;
    if (a.isSubFolder(b)) return 1;
    // Mantém a ordem do jeito que está.
    return 0;
  });

  return sortedFolders;
}
