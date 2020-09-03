import 'package:restler/data/entities/proxy_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/providers/proxy_provider.dart';

class ProxyRepository {
  final ProxyProvider proxyProvider;

  ProxyRepository(this.proxyProvider);

  Future<List<ProxyEntity>> all(WorkspaceEntity workspace) {
    return search(workspace, null);
  }

  Future<List<ProxyEntity>> search(
    WorkspaceEntity workspace,
    String text,
  ) async {
    final data = await proxyProvider.search(workspace?.uid, text);
    return [for (final item in data) ProxyEntity.fromDatabase(item)];
  }

  Future<ProxyEntity> get(String uid) async {
    if (uid == null) return null;
    final res = await proxyProvider.get(uid);
    return res != null && res.isNotEmpty ? ProxyEntity.fromDatabase(res) : null;
  }

  Future<bool> insert(ProxyEntity proxy) async {
    return proxyProvider.insert(proxy.toDatabase());
  }

  Future<bool> update(ProxyEntity proxy) async {
    return proxyProvider.update(
      proxy.uid,
      proxy.toDatabase(),
    );
  }

  Future<bool> delete(ProxyEntity proxy) async {
    return proxyProvider.delete(proxy.uid);
  }

  Future<bool> clear(WorkspaceEntity workspace) async {
    return proxyProvider.clear(workspace?.uid);
  }
}
