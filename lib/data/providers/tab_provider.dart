import 'package:restler/data/storage.dart';

class TabProvider {
  final Storage database;

  TabProvider(this.database);

  /// Obtém todas as abas.
  Future<List<Map<String, dynamic>>> all(String workspace) async {
    return database.rawQuery(workspace == null
        ? 'SELECT * FROM tab, request WHERE tab_workspace IS NULL AND tab_request = req_uid ORDER BY tab_opened_at DESC'
        : "SELECT * FROM tab, request, workspace WHERE tab_workspace = ws_uid AND tab_workspace = '$workspace' AND tab_request = req_uid ORDER BY tab_opened_at DESC");
  }

  /// Obtain uma determinada aba passando seu [uid].
  Future<Map<String, dynamic>> get(String uid) async {
    final data = await database.rawQuery(
        "SELECT * FROM tab JOIN request ON tab_request = req_uid LEFT JOIN workspace ON tab_workspace = ws_uid WHERE tab_uid = '$uid'");

    return data == null || data.isEmpty ? const <String, dynamic>{} : data[0];
  }

  /// Verifica se existe uma determinada aba com [uid].
  Future<bool> has(String uid) async {
    final res = await database
        .rawQuery('SELECT count(*) size FROM tab WHERE tab_uid = ?', [uid]);
    return res[0]['size'] == 1;
  }

  /// Insere uma nova aba passando seu [data].
  Future<bool> insert(Map<String, dynamic> data) async {
    return await database.insert('tab', data) > 0;
  }

  /// Atualiza uma determinada aba passando seu [uid] e [data].
  Future<bool> update(
    String uid,
    Map<String, dynamic> data,
  ) async {
    return await database.update(
          'tab',
          data,
          where: 'tab_uid = ?',
          whereArgs: [uid],
        ) ==
        1;
  }

  /// Remove uma determinada aba passando seu [uid].
  Future<bool> delete(String uid) async {
    return uid != null &&
        await database.delete(
              'tab',
              where: 'tab_uid = ?',
              whereArgs: [uid],
            ) ==
            1;
  }

  /// Remove todas as abas e retorna-as.
  Future<List<Map<String, dynamic>>> clear(String workspace) async {
    final res = <Map<String, dynamic>>[];
    // Obtêm as abas.
    final data = await database.rawQuery(
      workspace == null
          ? 'SELECT * FROM tab WHERE tab_workspace IS NULL'
          : "SELECT * FROM tab WHERE tab_workspace = '$workspace'",
    );
    // Para cada aba encontrada, remove-a.
    for (final item in data) {
      // Remove a aba.
      final deleted = await delete(item['tab_uid']);
      // Adiciona o item removido.
      if (deleted) {
        res.add(item);
      }
    }

    return res;
  }
}
