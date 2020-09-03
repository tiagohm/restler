import 'package:restler/data/entities/history_entity.dart';
import 'package:restler/data/providers/history_provider.dart';
import 'package:restler/data/providers/request_provider.dart';
import 'package:restler/data/providers/response_provider.dart';

class HistoryRepository {
  final HistoryProvider historyProvider;
  final RequestProvider requestProvider;
  final ResponseProvider responseProvider;

  HistoryRepository(
    this.requestProvider,
    this.responseProvider,
    this.historyProvider,
  );

  Future<List<HistoryEntity>> search({
    String text,
    String sortOrder = 'desc',
  }) async {
    final data = await historyProvider.search(text, sortOrder);

    return [
      for (final item in data) HistoryEntity.fromDatabase(item),
    ];
  }

  Future<bool> insert(HistoryEntity history) async {
    return (history.request == null ||
            await requestProvider.insert(history.request.toDatabase())) &&
        (history.response == null ||
            await responseProvider.insert(history.response.toDatabase())) &&
        await historyProvider.insert(history.toDatabase());
  }

  Future<bool> delete(HistoryEntity history) async {
    return await historyProvider.delete(history.uid) &&
        (history.request == null ||
            await requestProvider.delete(history.request.uid)) &&
        (history.response == null ||
            await responseProvider.delete(history.response.uid));
  }

  Future<bool> clear({
    int leaveAtLeast,
    String method,
    int startDate,
    int endDate,
  }) async {
    final deleted = await historyProvider.clear(
      leaveAtLeast: leaveAtLeast,
      method: method,
      startDate: startDate,
      endDate: endDate,
    );

    for (final item in deleted) {
      await requestProvider.delete(item['his_request']);
      await responseProvider.delete(item['his_response']);
    }

    return deleted.isNotEmpty;
  }
}
