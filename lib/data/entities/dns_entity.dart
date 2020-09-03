import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:sqler/sqler.dart';

final dnsTable = table('dns');
final dnsUid = col('dns_uid');
final dnsName = col('dns_name');
final dnsHttps = col('dns_https');
final dnsEnabled = col('dns_enabled');
final dnsAddress = col('dns_address');
final dnsPort = col('dns_port');
final dnsUrl = col('dns_url');
final dnsWorkspace = col('dns_workspace');

class DnsEntity extends Equatable {
  final String uid;
  final String name;
  final bool https;
  final bool enabled;
  // Over UDP.
  final String address;
  final int port;
  // Over HTTPS.
  final String url;
  final WorkspaceEntity workspace;

  const DnsEntity({
    this.uid,
    this.name,
    this.https = false,
    this.address = '',
    this.port = 53,
    this.url,
    this.enabled = true,
    this.workspace = WorkspaceEntity.empty,
  });

  static const empty = DnsEntity();

  factory DnsEntity.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return empty;
    } else {
      return DnsEntity(
        uid: json['uid'],
        name: json['name'],
        address: json['address'],
        port: json['port'],
        url: json['url'],
        https: json['https'] ?? false,
        enabled: json['enabled'],
        workspace: WorkspaceEntity.fromJson(json['workspace']),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'address': address,
      'url': url,
      'port': port,
      'https': https,
      'enabled': enabled,
      'workspace': workspace?.toJson(),
    };
  }

  DnsEntity.fromDatabase(Map<String, dynamic> db)
      : uid = db['dns_uid'],
        name = db['dns_name'],
        address = db['dns_address'],
        url = db['dns_url'],
        port = db['dns_port'],
        enabled = db['dns_enabled'] == 1,
        https = db['dns_https'] == 1,
        workspace = WorkspaceEntity.fromDatabase(db);

  Map<String, dynamic> toDatabase() {
    return {
      'dns_uid': uid,
      'dns_name': name,
      'dns_address': address,
      'dns_url': url,
      'dns_port': port,
      'dns_enabled': enabled ? 1 : 0,
      'dns_https': https ? 1 : 0,
      'dns_workspace': workspace?.uid,
    };
  }

  DnsEntity copyWith({
    String uid,
    String name,
    String address,
    String url,
    int port,
    bool https,
    bool enabled,
    WorkspaceEntity workspace,
  }) {
    return DnsEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      address: address ?? this.address,
      port: port ?? this.port,
      url: url ?? this.url,
      https: https ?? this.https,
      enabled: enabled ?? this.enabled,
      workspace: workspace ?? this.workspace,
    );
  }

  @override
  List get props => [
        uid,
        name,
        address,
        port,
        enabled,
        url,
        https,
        workspace,
      ];

  @override
  String toString() {
    return 'Dns { uid: $uid, name: $name, address: $address, port: $port, enabled: $enabled,'
        ' url: $url, https: $https, workspace: $workspace }';
  }
}
