import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/variable_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/storage.dart';
import 'package:sqler/sqler.dart';

class VariableProvider {
  final Storage database;

  VariableProvider(this.database);

  Future<List<Map<String, dynamic>>> all(
    String workspace,
    String environment,
  ) async {
    final q = QueryBuilder()
      ..from(variableTable)
      ..leftJoin(environmentTable,
          on: [eq(variableEnvironment, environmentUid)])
      ..leftJoin(workspaceTable, on: [eq(variableWorkspace, workspaceUid)])
      ..where(eq(variableWorkspace, workspace))
      ..where(eq(variableEnvironment, environment));

    return database.rawQuery(q.sql());
  }

  Future<List<Map<String, dynamic>>> search(
    String workspace,
    String environment, {
    String text,
  }) async {
    var q = QueryBuilder()
      ..from(variableTable)
      ..leftJoin(environmentTable,
          on: [eq(variableEnvironment, environmentUid)])
      ..leftJoin(workspaceTable, on: [eq(variableWorkspace, workspaceUid)])
      ..where(eq(variableWorkspace, workspace))
      ..where(eq(variableEnvironment, environment));

    // Filtra por name ou value.
    if (text != null && text.isNotEmpty) {
      q = q
        ..where(likeAnywhere(variableName, text) |
            likeAnywhere(variableValue, text));
    }

    // Ordena por nome.
    q = q..orderBy(asc(variableName));

    return database.rawQuery(q.sql());
  }

  Future<Map<String, dynamic>> get(String uid) async {
    final q = QueryBuilder()
      ..from(variableTable)
      ..leftJoin(environmentTable,
          on: [eq(variableEnvironment, environmentUid)])
      ..leftJoin(workspaceTable, on: [eq(variableWorkspace, workspaceUid)])
      ..where(eq(variableUid, uid));

    final data = await database.rawQuery(q.sql());

    return data == null || data.isEmpty ? null : data[0];
  }

  Future<bool> insert(Map<String, dynamic> data) async {
    return await database.insert('variable', data) > 0;
  }

  Future<bool> update(
    String uid,
    Map<String, dynamic> data,
  ) async {
    return await database.update(
          'variable',
          data,
          where: 'var_uid = ?',
          whereArgs: [uid],
        ) ==
        1;
  }

  Future<bool> delete(String uid) async {
    return uid != null &&
        await database.delete(
              'variable',
              where: 'var_uid = ?',
              whereArgs: [uid],
            ) ==
            1;
  }

  Future<bool> clearByWorkspace(String workspace) async {
    final sql = workspace == null
        ? 'DELETE FROM variable WHERE var_workspace IS NULL'
        : "DELETE FROM variable WHERE var_workspace = '$workspace'";
    return await database.rawDelete(sql) > 0;
  }

  Future<bool> clearByEnvironment(
    String workspace,
    String environment,
  ) async {
    String sql;

    if (workspace == null && environment == null) {
      sql =
          'DELETE FROM variable WHERE var_workspace IS NULL AND var_environment IS NULL';
    } else if (workspace == null && environment != null) {
      sql =
          "DELETE FROM variable WHERE var_workspace IS NULL AND var_environment = '$environment'";
    } else if (workspace != null && environment == null) {
      sql =
          "DELETE FROM variable WHERE var_workspace = '$workspace' AND var_environment IS NULL";
    } else {
      sql =
          "DELETE FROM variable WHERE var_workspace = '$workspace' AND var_environment = '$environment'";
    }

    return await database.rawDelete(sql) > 0;
  }
}
