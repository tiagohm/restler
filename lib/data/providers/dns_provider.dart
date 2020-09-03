import 'package:restler/data/entities/dns_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/storage.dart';
import 'package:sqler/sqler.dart';

class DnsProvider {
  final Storage database;

  DnsProvider(this.database);

  Future<List<Map<String, dynamic>>> all(String workspace) async {
    final q = QueryBuilder()
      ..from(dnsTable)
      ..leftJoin(workspaceTable, on: [eq(dnsWorkspace, workspaceUid)])
      ..where(eq(dnsWorkspace, workspace))
      ..orderBy(asc(dnsName));

    return database.rawQuery(q.sql());
  }

  Future<List<Map<String, dynamic>>> search(
    String workspace,
    String text,
  ) async {
    var q = QueryBuilder()
      ..from(dnsTable)
      ..leftJoin(workspaceTable, on: [eq(dnsWorkspace, workspaceUid)]);

    // Workspace.
    q = q..where(eq(dnsWorkspace, workspace));

    // Texto.
    if (text != null && text.isNotEmpty) {
      q = q
        ..where(likeAnywhere(dnsName, text) |
            likeAnywhere(dnsAddress, text) |
            likeAnywhere(dnsUrl, text));
    }

    // Ordena por nome.
    q = q..orderBy(asc(dnsName));

    return database.rawQuery(q.sql());
  }

  Future<Map<String, dynamic>> get(String uid) async {
    final q = QueryBuilder()
      ..from(dnsTable)
      ..leftJoin(workspaceTable, on: [eq(dnsWorkspace, workspaceUid)])
      ..where(eq(dnsUid, uid));

    final data = await database.rawQuery(q.sql());

    return data == null || data.isEmpty ? null : data[0];
  }

  Future<bool> insert(Map<String, dynamic> data) async {
    return await database.insert('dns', data) > 0;
  }

  Future<bool> update(
    String uid,
    Map<String, dynamic> data,
  ) async {
    return await database.update(
          'dns',
          data,
          where: 'dns_uid = ?',
          whereArgs: [uid],
        ) ==
        1;
  }

  Future<bool> delete(String uid) async {
    return uid != null &&
        await database.delete(
              'dns',
              where: 'dns_uid = ?',
              whereArgs: [uid],
            ) ==
            1;
  }

  Future<bool> clear(String workspace) async {
    final q = await database.rawDelete(workspace == null
        ? 'DELETE FROM dns WHERE dns_workspace IS NULL'
        : "DELETE FROM dns WHERE dns_workspace = '$workspace'");
    return q > 0;
  }
}
