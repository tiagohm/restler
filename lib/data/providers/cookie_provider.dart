import 'package:restler/data/entities/cookie_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/storage.dart';
import 'package:sqler/sqler.dart';

class CookieProvider {
  final Storage database;

  CookieProvider(this.database);

  Future<List<Map<String, dynamic>>> all(String workspace) async {
    final q = QueryBuilder()
      ..from(cookieTable)
      ..leftJoin(workspaceTable, on: [eq(cookieWorkspace, workspaceUid)])
      ..where(eq(cookieWorkspace, workspace))
      ..orderBy(asc(cookieDomain))
      ..orderBy(asc(cookiePath))
      ..orderBy(asc(cookieName));

    return database.rawQuery(q.sql());
  }

  Future<List<Map<String, dynamic>>> search(
    String workspace, {
    String domain,
    String path,
    String name,
    String text,
  }) async {
    var q = QueryBuilder()
      ..from(cookieTable)
      ..leftJoin(workspaceTable, on: [eq(cookieWorkspace, workspaceUid)]);

    // Workspace.
    q = q..where(eq(cookieWorkspace, workspace));

    // um cookie com domain google.com irá ser enviado para google.com, www.google.com, etc.
    // por isso, verificamos se existe um cookie que casa seu final com o domain.
    if (domain != null && domain.isNotEmpty) {
      q = q..where(likeEnd(domain, cookieDomain));
    }

    // Um cookie com path '/' irá ser enviado para '/', '/blablabla' e '/blabla/blabla', etc.
    // por isso, verificamos se existe um cookie que casa seu início com o path.
    if (path != null && path.isNotEmpty) {
      q = q..where(likeStart(path, cookiePath));
    }

    // Name.
    if (name != null && name.isNotEmpty) {
      q = q..where(likeAnywhere(cookieName, name));
    }

    // Texto.
    if (text != null && text.isNotEmpty) {
      q = q
        ..where(likeAnywhere(cookieDomain, text) |
            likeAnywhere(cookiePath, text) |
            likeAnywhere(cookieName, text) |
            likeAnywhere(cookieValue, text));
    }

    // Ordena por nome.
    q = q
      ..orderBy(asc(cookieDomain))
      ..orderBy(asc(cookiePath))
      ..orderBy(asc(cookieName));

    return database.rawQuery(q.sql());
  }

  Future<bool> insert(Map<String, dynamic> data) async {
    return await database.insert('cookie', data) > 0;
  }

  Future<bool> update(
    String uid,
    Map<String, dynamic> data,
  ) async {
    return await database.update(
          'cookie',
          data,
          where: 'cook_uid = ?',
          whereArgs: [uid],
        ) ==
        1;
  }

  Future<bool> delete(String uid) async {
    return uid != null &&
        await database.delete(
              'cookie',
              where: 'cook_uid = ?',
              whereArgs: [uid],
            ) ==
            1;
  }

  Future<bool> clear(String workspace) async {
    final q = await database.rawDelete(workspace == null
        ? 'DELETE FROM cookie WHERE cook_workspace IS NULL'
        : "DELETE FROM cookie WHERE cook_workspace = '$workspace'");
    return q > 0;
  }
}
