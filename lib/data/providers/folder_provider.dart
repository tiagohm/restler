import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/storage.dart';
import 'package:sqler/sqler.dart';

class FolderProvider {
  final Storage database;

  FolderProvider(this.database);

  Future<List<Map<String, dynamic>>> all(String workspace) async {
    final q = QueryBuilder()
      ..from(folderTable)
      ..leftJoin(workspaceTable, on: [eq(folderWorkspace, workspaceUid)])
      ..where(eq(folderWorkspace, workspace))
      ..orderBy(asc(folderParent));

    return database.rawQuery(q.sql());
  }

  Future<Map<String, dynamic>> get(String uid) async {
    final q = QueryBuilder()
      ..from(folderTable)
      ..leftJoin(workspaceTable, on: [eq(folderWorkspace, workspaceUid)])
      ..where(eq(folderUid, uid));

    final data = await database.rawQuery(q.sql());

    return data == null || data.isEmpty ? null : data[0];
  }

  Future<List<Map<String, dynamic>>> search(
    String workspace, {
    String text,
    String parent,
  }) async {
    var q = QueryBuilder()
      ..from(folderTable)
      ..leftJoin(workspaceTable, on: [eq(folderWorkspace, workspaceUid)]);

    // Workspace.
    q = q..where(eq(folderWorkspace, workspace));

    // Texto.
    if (text != null && text.isNotEmpty) {
      q = q..where(likeAnywhere(folderName, text));
    }

    // Pasta-pai.
    q = q..where(eq(folderParent, parent));

    // Ordena por favoritos e nome.
    q = q..orderBy(desc(folderFavorite))..orderBy(asc(folderName));

    return database.rawQuery(q.sql());
  }

  Future<bool> insert(Map<String, dynamic> data) async {
    return await database.insert('folder', data) > 0;
  }

  Future<bool> update(
    String uid,
    Map<String, dynamic> data,
  ) async {
    return await database.update(
          'folder',
          data,
          where: 'fol_uid = ?',
          whereArgs: [uid],
        ) ==
        1;
  }

  Future<bool> delete(String uid) async {
    return uid != null &&
        await database.delete(
              'folder',
              where: 'fol_uid = ?',
              whereArgs: [uid],
            ) ==
            1;
  }

  Future<int> numberOfFolders(String uid) async {
    final q = QueryBuilder()
      ..from(folderTable)
      ..column(count(alias: 'a'))
      ..where(eq(folderParent, uid));

    final data = await database.rawQuery(q.sql());

    return data[0]['a'];
  }
}
