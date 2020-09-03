import 'dart:convert';

import 'package:restler/crypto.dart';
import 'package:restler/services/import_export.dart';

class RestlerExporter extends Exporter {
  @override
  String export(
    ImportExportData data, {
    String fileType,
    String password,
    String name,
  }) {
    final edata = {
      'workspaces': data.workspaces ?? const [],
      'folders': data.folders ?? const [],
      'requests': data.requests ?? const [],
      'cookies': data.cookies ?? const [],
      'proxies': data.proxies ?? const [],
      'dns': data.dns ?? const [],
    };

    final encrypted = isEncrypted(password);

    return json.encode({
      'encrypted': encrypted,
      // Se criptografado, gerar uma String em base64.
      // Caso contrário, gerar um objeto.
      'data': encrypted ? encrypt(json.encode(edata), password) : edata,
    });
  }

  bool isEncrypted(String password) {
    return password != null && password.trim().isNotEmpty;
  }
}
