import 'package:restler/data/entities/dns_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/providers/dns_provider.dart';

class DnsRepository {
  final DnsProvider dnsProvider;

  DnsRepository(this.dnsProvider);

  Future<List<DnsEntity>> all(WorkspaceEntity workspace) {
    return search(workspace, null);
  }

  Future<List<DnsEntity>> search(
    WorkspaceEntity workspace,
    String text,
  ) async {
    final data = await dnsProvider.search(workspace?.uid, text);
    return _mapDataToDnsList(data);
  }

  static List<DnsEntity> _mapDataToDnsList(
    List<Map<String, dynamic>> data,
  ) {
    return [
      for (final item in data) DnsEntity.fromDatabase(item),
    ];
  }

  Future<DnsEntity> get(String uid) async {
    if (uid == null) return null;
    final res = await dnsProvider.get(uid);
    return res != null && res.isNotEmpty ? DnsEntity.fromDatabase(res) : null;
  }

  Future<bool> insert(DnsEntity dns) async {
    return dnsProvider.insert(dns.toDatabase());
  }

  Future<bool> update(DnsEntity dns) async {
    return dnsProvider.update(
      dns.uid,
      dns.toDatabase(),
    );
  }

  Future<bool> delete(DnsEntity dns) async {
    return dnsProvider.delete(dns.uid);
  }

  Future<bool> clear(WorkspaceEntity workspace) async {
    return dnsProvider.clear(workspace?.uid);
  }
}
