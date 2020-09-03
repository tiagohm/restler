import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/storage.dart';
import 'package:sqler/sqler.dart';

class RequestProvider {
  final Storage database;

  RequestProvider(this.database);

  Future<List<Map<String, dynamic>>> all() async {
    return database.query('request');
  }

  Future<Map<String, dynamic>> get(String uid) async {
    final q = QueryBuilder()
      ..from(requestTable)
      ..where(eq(requestUid, uid));

    final data = await database.rawQuery(q.sql());

    return data == null || data.isEmpty ? null : data[0];
  }

  Future<bool> insert(Map<String, dynamic> data) async {
    return await database.insert('request', data) > 0;
  }

  Future<bool> update(
    String uid,
    Map<String, dynamic> data,
  ) async {
    return await database.update(
          'request',
          data,
          where: 'req_uid = ?',
          whereArgs: [uid],
        ) ==
        1;
  }

  Future<bool> delete(String uid) async {
    return uid != null &&
        await database.delete(
              'request',
              where: 'req_uid = ?',
              whereArgs: [uid],
            ) ==
            1;
  }
}
