import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/storage.dart';
import 'package:sqler/sqler.dart';

class WorkspaceProvider {
  final Storage database;

  WorkspaceProvider(this.database);

  /// Obtém todos os workspaces.
  Future<List<Map<String, dynamic>>> all() async {
    final q = QueryBuilder()
      ..from(workspaceTable)
      ..orderBy(desc(workspaceActive))
      ..orderBy(asc(workspaceName));

    return database.rawQuery(q.sql());
  }

  /// Obtém um determinado workspace passando seu [uid].
  Future<Map<String, dynamic>> get(String uid) async {
    final q = QueryBuilder()
      ..from(workspaceTable)
      ..where(eq(workspaceUid, uid));

    final data = await database.rawQuery(q.sql());

    return data == null || data.isEmpty ? null : data[0];
  }

  /// Verifica se existe um determinado workspace com [uid].
  Future<bool> has(String uid) async {
    final q = QueryBuilder()
      ..column(count(alias: 'a'))
      ..from(workspaceTable)
      ..where(eq(workspaceUid, uid));

    final data = await database.rawQuery(q.sql());

    return data[0]['a'] == 1;
  }

  /// Insere um novo workspace passando seu [data].
  Future<bool> insert(Map<String, dynamic> data) async {
    return await database.insert('workspace', data) > 0;
  }

  /// Atualiza um determinado workspace passando seu [uid] e [data].
  Future<bool> update(
    String uid,
    Map<String, dynamic> data,
  ) async {
    return await database.update(
          'workspace',
          data,
          where: 'ws_uid = ?',
          whereArgs: [uid],
        ) ==
        1;
  }

  /// Remove um determinado workspace passando seu [uid].
  Future<bool> delete(String uid) async {
    return uid != null &&
        await database.delete(
              'workspace',
              where: 'ws_uid = ?',
              whereArgs: [uid],
            ) ==
            1;
  }

  /// Obtém o workspace ativo.
  Future<Map<String, dynamic>> active() async {
    final q = QueryBuilder()
      ..from(workspaceTable)
      ..orderBy(desc(workspaceActive))
      ..limit(limit(1));

    final data = await database.rawQuery(q.sql());

    return data == null || data.isEmpty ? null : data[0];
  }
}
