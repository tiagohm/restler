import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/storage.dart';
import 'package:sqler/sqler.dart';

class EnvironmentProvider {
  final Storage database;

  EnvironmentProvider(this.database);

  Future<List<Map<String, dynamic>>> all(String workspace) async {
    final q = QueryBuilder()
      ..from(environmentTable)
      ..leftJoin(workspaceTable, on: [eq(environmentWorkspace, workspaceUid)])
      ..where(eq(environmentWorkspace, workspace))
      ..orderBy(asc(environmentName));

    return database.rawQuery(q.sql());
  }

  Future<List<Map<String, dynamic>>> search(
    String workspace, {
    String text,
    bool enabled,
  }) async {
    var q = QueryBuilder()
      ..from(environmentTable)
      ..leftJoin(workspaceTable, on: [eq(environmentWorkspace, workspaceUid)]);

    // Workspace.
    q = q..where(eq(environmentWorkspace, workspace));

    // Texto.
    if (text != null && text.isNotEmpty) {
      q = q..where(likeAnywhere(environmentName, text));
    }

    // Filtra por enabled.
    if (enabled != null) {
      q = q..where(eq(environmentEnabled, enabled));
    }

    // Ordena por nome.
    q = q..orderBy(asc(environmentName));

    return database.rawQuery(q.sql());
  }

  Future<Map<String, dynamic>> get(String uid) async {
    final q = QueryBuilder()
      ..from(environmentTable)
      ..leftJoin(workspaceTable, on: [eq(environmentWorkspace, workspaceUid)])
      ..where(eq(environmentUid, uid));

    final data = await database.rawQuery(q.sql());

    return data == null || data.isEmpty ? null : data[0];
  }

  Future<bool> insert(Map<String, dynamic> data) async {
    return await database.insert('environment', data) > 0;
  }

  Future<bool> update(
    String uid,
    Map<String, dynamic> data,
  ) async {
    return await database.update(
          'environment',
          data,
          where: 'env_uid = ?',
          whereArgs: [uid],
        ) ==
        1;
  }

  Future<bool> delete(String uid) async {
    return uid != null &&
        await database.delete(
              'environment',
              where: 'env_uid = ?',
              whereArgs: [uid],
            ) ==
            1;
  }

  /// Obtém o ambiente ativo.
  Future<Map<String, dynamic>> active(String workspace) async {
    final q = QueryBuilder()
      ..from(environmentTable)
      ..leftJoin(workspaceTable, on: [eq(environmentWorkspace, workspaceUid)])
      ..where(eq(environmentWorkspace, workspace))
      ..where(eq(environmentActive, 1))
      ..orderBy(desc(environmentEnabled))
      ..limit(limit(1));

    final data = await database.rawQuery(q.sql());

    return data == null || data.isEmpty ? null : data[0];
  }
}
