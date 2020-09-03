import 'package:restler/data/entities/proxy_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/storage.dart';
import 'package:sqler/sqler.dart';

class ProxyProvider {
  final Storage database;

  ProxyProvider(this.database);

  Future<List<Map<String, dynamic>>> all(String workspace) async {
    final q = QueryBuilder()
      ..from(proxyTable)
      ..leftJoin(workspaceTable, on: [eq(proxyWorkspace, workspaceUid)])
      ..where(eq(proxyWorkspace, workspace))
      ..orderBy(asc(proxyName));

    return database.rawQuery(q.sql());
  }

  Future<List<Map<String, dynamic>>> search(
    String workspace,
    String text,
  ) async {
    var q = QueryBuilder()
      ..from(proxyTable)
      ..leftJoin(workspaceTable, on: [eq(proxyWorkspace, workspaceUid)]);

    // Workspace.
    q = q..where(eq(proxyWorkspace, workspace));

    // Texto.
    if (text != null && text.isNotEmpty) {
      q = q
        ..where(likeAnywhere(proxyName, text) | likeAnywhere(proxyHost, text));
    }

    // Ordena por nome.
    q = q..orderBy(asc(proxyName));

    return database.rawQuery(q.sql());
  }

  Future<Map<String, dynamic>> get(String uid) async {
    final q = QueryBuilder()
      ..from(proxyTable)
      ..leftJoin(workspaceTable, on: [eq(proxyWorkspace, workspaceUid)])
      ..where(eq(proxyUid, uid));

    final data = await database.rawQuery(q.sql());

    return data == null || data.isEmpty ? null : data[0];
  }

  Future<bool> insert(Map<String, dynamic> data) async {
    return await database.insert('proxy', data) > 0;
  }

  Future<bool> update(
    String uid,
    Map<String, dynamic> data,
  ) async {
    return await database.update(
          'proxy',
          data,
          where: 'pro_uid = ?',
          whereArgs: [uid],
        ) ==
        1;
  }

  Future<bool> delete(String uid) async {
    return uid != null &&
        await database.delete(
              'proxy',
              where: 'pro_uid = ?',
              whereArgs: [uid],
            ) ==
            1;
  }

  Future<bool> clear(String workspace) async {
    final q = await database.rawDelete(workspace == null
        ? 'DELETE FROM proxy WHERE pro_workspace IS NULL'
        : "DELETE FROM proxy WHERE pro_workspace = '$workspace'");
    return q > 0;
  }
}
