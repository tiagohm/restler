import 'package:restler/data/entities/certificate_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/storage.dart';
import 'package:sqler/sqler.dart';

class CertificateProvider {
  final Storage database;

  CertificateProvider(this.database);

  Future<List<Map<String, dynamic>>> all(String workspace) async {
    final q = QueryBuilder()
      ..from(certificateTable)
      ..leftJoin(workspaceTable, on: [eq(certificateWorkspace, workspaceUid)])
      ..where(eq(certificateWorkspace, workspace))
      ..orderBy(asc(certificateHost));

    return database.rawQuery(q.sql());
  }

  Future<List<Map<String, dynamic>>> search(
    String workspace,
    String text,
  ) async {
    var q = QueryBuilder()
      ..from(certificateTable)
      ..leftJoin(workspaceTable, on: [eq(certificateWorkspace, workspaceUid)]);

    // Workspace.
    q = q..where(eq(certificateWorkspace, workspace));

    // Texto.
    if (text != null && text.isNotEmpty) {
      q = q..where(likeAnywhere(certificateHost, text));
    }

    // Ordena por nome.
    q = q..orderBy(asc(certificateHost));

    return database.rawQuery(q.sql());
  }

  Future<Map<String, dynamic>> get(String uid) async {
    final q = QueryBuilder()
      ..from(certificateTable)
      ..leftJoin(workspaceTable, on: [eq(certificateWorkspace, workspaceUid)])
      ..where(eq(certificateUid, uid));

    final data = await database.rawQuery(q.sql());

    return data == null || data.isEmpty ? null : data[0];
  }

  Future<bool> insert(Map<String, dynamic> data) async {
    return await database.insert('certificate', data) > 0;
  }

  Future<bool> update(
    String uid,
    Map<String, dynamic> data,
  ) async {
    return await database.update(
          'certificate',
          data,
          where: 'cert_uid = ?',
          whereArgs: [uid],
        ) ==
        1;
  }

  Future<bool> delete(String uid) async {
    return uid != null &&
        await database.delete(
              'certificate',
              where: 'cert_uid = ?',
              whereArgs: [uid],
            ) ==
            1;
  }

  Future<bool> clear(String workspace) async {
    final q = await database.rawDelete(workspace == null
        ? 'DELETE FROM certificate WHERE cert_workspace IS NULL'
        : "DELETE FROM certificate WHERE cert_workspace = '$workspace'");
    return q > 0;
  }
}
