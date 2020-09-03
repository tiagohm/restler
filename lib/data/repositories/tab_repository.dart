import 'package:restler/data/entities/tab_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/providers/request_provider.dart';
import 'package:restler/data/providers/tab_provider.dart';

class TabRepository {
  final TabProvider tabProvider;
  final RequestProvider requestProvider;

  TabRepository(
    this.requestProvider,
    this.tabProvider,
  );

  Future<List<TabEntity>> all(WorkspaceEntity workspace) async {
    final data = await tabProvider.all(workspace?.uid);
    return [for (final item in data) TabEntity.fromDatabase(item)];
  }

  Future<bool> has(TabEntity tab) async {
    return tabProvider.has(tab.uid);
  }

  Future<bool> insert(TabEntity tab) async {
    return (tab.request == null ||
            await requestProvider.insert(tab.request.toDatabase())) &&
        await tabProvider.insert(tab.toDatabase());
  }

  Future<bool> update(TabEntity tab) async {
    return (tab.request == null ||
            await requestProvider.update(
              tab.request.uid,
              tab.request.toDatabase(),
            )) &&
        await tabProvider.update(tab.uid, tab.toDatabase());
  }

  Future<bool> delete(TabEntity tab) async {
    return await tabProvider.delete(tab.uid) &&
        await requestProvider.delete(tab.request?.uid);
  }

  Future<bool> clear(WorkspaceEntity workspace) async {
    final tabs = await tabProvider.clear(workspace?.uid);

    for (final tab in tabs) {
      await requestProvider.delete(tab['tab_request']);
    }

    return true;
  }
}
