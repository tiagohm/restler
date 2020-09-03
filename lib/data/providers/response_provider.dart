import 'package:restler/data/entities/response_entity.dart';
import 'package:restler/data/storage.dart';
import 'package:sqler/sqler.dart';

class ResponseProvider {
  final Storage database;

  ResponseProvider(this.database);

  Future<Map<String, dynamic>> get(String uid) async {
    final q = QueryBuilder()
      ..from(responseTable)
      ..where(eq(responseUid, uid));

    final data = await database.rawQuery(q.sql());

    return data == null || data.isEmpty ? null : data[0];
  }

  Future<bool> insert(Map<String, dynamic> data) async {
    return await database.insert('response', data) > 0;
  }

  Future<bool> update(
    String uid,
    Map<String, dynamic> data,
  ) async {
    return uid != null &&
        await database.update(
              'response',
              data,
              where: 'resp_uid = ?',
              whereArgs: [uid],
            ) ==
            1;
  }

  Future<bool> delete(String uid) async {
    return uid != null &&
        await database.delete(
              'response',
              where: 'resp_uid = ?',
              whereArgs: [uid],
            ) ==
            1;
  }
}
