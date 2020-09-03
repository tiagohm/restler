import 'package:restler/data/entities/history_entity.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/response_entity.dart';
import 'package:restler/data/storage.dart';
import 'package:sqler/sqler.dart';

class HistoryProvider {
  final Storage database;

  HistoryProvider(this.database);

  Future<List<Map<String, dynamic>>> search(
    String text,
    String sortOrder,
  ) async {
    var q = QueryBuilder()
      ..column(tableAll(historyTable))
      ..column(tableAll(requestTable))
      ..columns([responseUid, responseStatus, responseTime])
      ..columns([responseContentType, responseHeaders, responseCookies])
      ..columns([responseRedirects, responseDataSize])
      ..from(historyTable)
      ..innerJoin(requestTable, on: [eq(historyRequest, requestUid)])
      ..innerJoin(responseTable, on: [eq(historyResponse, responseUid)]);

    // Texto.
    if (text != null && text.isNotEmpty) {
      q = q
        ..where(likeAnywhere(requestMethod, text) |
            eq(responseStatus, text) |
            likeAnywhere(requestUrl, text));
    }

    // Ordena por data.
    final sorter = sortOrder == 'desc' ? desc : asc;
    q = q..orderBy(sorter(historyDate));

    return database.rawQuery(q.sql());
  }

  Future<bool> insert(Map<String, dynamic> data) async {
    return await database.insert('history', data) > 0;
  }

  Future<bool> delete(String uid) async {
    return uid != null &&
        await database.delete(
              'history',
              where: 'his_uid = ?',
              whereArgs: [uid],
            ) ==
            1;
  }

  Future<List<Map<String, dynamic>>> clear({
    int leaveAtLeast,
    String method,
    int startDate, // inclusive
    int endDate, // exclusive
  }) async {
    final res = <Map<String, dynamic>>[];
    dynamic data;

    var q = QueryBuilder()..from(historyTable);

    // Limpar o histórico e deixar pelo menos [leaveAtLeast] mais recente.
    if (leaveAtLeast != null && leaveAtLeast >= 0) {
      q = q..limit(offset(leaveAtLeast));
    }
    // Limpar o histórico enviado antes de tal data.
    else if (startDate == null && endDate != null) {
      q = q..where(lt(historyDate, endDate));
    }
    // Limpa o histórico enviado depois de tal data.
    else if (startDate != null && endDate == null) {
      q = q..where(ge(historyDate, startDate));
    }
    // Limpa o histórico enviado dentro de um intervalo.
    else if (startDate != null && endDate != null) {
      q = q..where(ge(historyDate, startDate))..where(lt(historyDate, endDate));
    }
    // Limpa o histórico por método.
    else if (method != null) {
      q = q
        ..innerJoin(requestTable, on: [eq(historyRequest, requestUid)])
        ..where(eq(requestMethod, method));
    }

    q = q..orderBy(desc(historyDate));

    data = await database.rawQuery(q.sql());

    if (data != null) {
      // Para cada histórico encontrado, remove-o.
      for (final item in data) {
        // Remove o histórico.
        if (await delete(item['his_uid'])) {
          // Adiciona a lista de itens removidos.
          res.add(item);
        }
      }
    }

    return res;
  }
}
