import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/storage.dart';
import 'package:sqler/sqler.dart';

class CallProvider {
  final Storage database;

  CallProvider(this.database);

  Future<List<Map<String, dynamic>>> all(String workspace) async {
    final q = QueryBuilder()
      ..from(callTable)
      ..innerJoin(requestTable, on: [eq(callRequest, requestUid)])
      ..leftJoin(workspaceTable, on: [eq(callWorkspace, workspaceUid)])
      ..where(eq(callWorkspace, workspace))
      ..orderBy(asc(callFolder));

    return database.rawQuery(q.sql());
  }

  Future<Map<String, dynamic>> get(String uid) async {
    final q = QueryBuilder()
      ..from(callTable)
      ..innerJoin(requestTable, on: [eq(callRequest, requestUid)])
      ..leftJoin(workspaceTable, on: [eq(callWorkspace, workspaceUid)])
      ..where(eq(callUid, uid));

    final data = await database.rawQuery(q.sql());

    return data == null || data.isEmpty ? null : data[0];
  }

  Future<List<Map<String, dynamic>>> search(
    String workspace, {
    String text,
    String folder,
  }) async {
    var q = QueryBuilder()
      ..from(callTable)
      ..innerJoin(requestTable, on: [eq(callRequest, requestUid)])
      ..leftJoin(workspaceTable, on: [eq(callWorkspace, workspaceUid)]);

    // Workspace.
    q = q..where(eq(callWorkspace, workspace));

    // Texto.
    if (text != null && text.isNotEmpty) {
      q = q
        ..where(likeAnywhere(callName, text) |
            likeAnywhere(requestMethod, text) |
            likeAnywhere(requestUrl, text));
    }

    // Pasta.
    q = q..where(eq(callFolder, folder));

    // Ordena por favoritos e nome.
    q = q..orderBy(desc(callFavorite))..orderBy(asc(callName));

    return database.rawQuery(q.sql());
  }

  Future<bool> insert(Map<String, dynamic> data) async {
    return await database.insert('call', data) > 0;
  }

  Future<bool> update(
    String uid,
    Map<String, dynamic> data,
  ) async {
    return await database.update(
          'call',
          data,
          where: 'call_uid = ?',
          whereArgs: [uid],
        ) ==
        1;
  }

  Future<bool> delete(String uid) async {
    return uid != null &&
        await database.delete(
              'call',
              where: 'call_uid = ?',
              whereArgs: [uid],
            ) ==
            1;
  }

  Future<int> numberOfCalls(String uid) async {
    final q = QueryBuilder()
      ..from(callTable)
      ..column(count(alias: 'a'))
      ..where(eq(callFolder, uid));

    final data = await database.rawQuery(q.sql());

    return data[0]['a'];
  }
}
