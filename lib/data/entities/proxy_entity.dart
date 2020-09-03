import 'package:equatable/equatable.dart';
import 'package:restio/restio.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:sqler/sqler.dart';

final proxyTable = table('proxy');
final proxyUid = col('pro_uid');
final proxyName = col('pro_name');
final proxyHost = col('pro_host');
final proxyPort = col('pro_port');
final proxyHttp = col('pro_http');
final proxyHttps = col('pro_https');
final proxyUsername = col('pro_username');
final proxyPassword = col('pro_password');
final proxyWorkspace = col('pro_workspace');

class ProxyEntity extends Equatable implements Proxy {
  final String uid;
  final String name;
  @override
  final String host;
  @override
  final int port;
  @override
  final bool http;
  @override
  final bool https;
  @override
  final BasicAuthenticator auth;
  final bool enabled;
  final WorkspaceEntity workspace;

  const ProxyEntity({
    this.uid,
    this.name,
    this.host = '',
    this.port,
    this.http = true,
    this.https = true,
    this.auth,
    this.enabled = true,
    this.workspace = WorkspaceEntity.empty,
  });

  static const empty = ProxyEntity();

  factory ProxyEntity.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return empty;
    } else {
      return ProxyEntity(
        uid: json['uid'],
        name: json['name'],
        host: json['host'],
        port: json['port'],
        http: json['http'] ?? true,
        https: json['https'] ?? true,
        auth: json['auth'] == true
            ? BasicAuthenticator(
                username: json['username'],
                password: json['password'],
              )
            : null,
        enabled: json['enabled'],
        workspace: WorkspaceEntity.fromJson(json['workspace']),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'host': host,
      'port': port,
      'http': http,
      'https': https,
      'auth': auth != null,
      'username': auth?.username ?? '',
      'password': auth?.password ?? '',
      'enabled': enabled,
      'workspace': workspace?.toJson(),
    };
  }

  ProxyEntity.fromDatabase(Map<String, dynamic> db)
      : uid = db['pro_uid'],
        name = db['pro_name'],
        host = db['pro_host'],
        port = db['pro_port'],
        enabled = db['pro_enabled'] == 1,
        http = db['pro_http'] == 1,
        https = db['pro_https'] == 1,
        auth = db['pro_auth'] == 1
            ? BasicAuthenticator(
                username: db['pro_username'],
                password: db['pro_password'],
              )
            : null,
        workspace = WorkspaceEntity.fromDatabase(db);

  Map<String, dynamic> toDatabase() {
    return {
      'pro_uid': uid,
      'pro_name': name,
      'pro_host': host,
      'pro_port': port,
      'pro_enabled': enabled ? 1 : 0,
      'pro_http': http ? 1 : 0,
      'pro_https': https ? 1 : 0,
      'pro_auth': auth != null ? 1 : 0,
      'pro_username': auth?.username ?? '',
      'pro_password': auth?.password ?? '',
      'pro_workspace': workspace?.uid,
    };
  }

  ProxyEntity copyWith({
    String uid,
    String name,
    String host,
    int port,
    bool http,
    bool https,
    BasicAuthenticator auth,
    bool enabled,
    WorkspaceEntity workspace,
  }) {
    return ProxyEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      http: http ?? this.http,
      https: https ?? this.https,
      auth: auth ?? this.auth,
      enabled: enabled ?? this.enabled,
      workspace: workspace ?? this.workspace,
    );
  }

  @override
  List get props => [
        uid,
        name,
        host,
        port,
        enabled,
        http,
        https,
        auth?.username,
        auth?.password,
        workspace,
      ];

  @override
  String toString() {
    return 'Proxy { uid: $uid, name: $name, host: $host, port: $port,'
        ' enabled: $enabled, http: $http, https: $https, username: ${auth?.username}, password: ${auth?.password},'
        ' workspace: $workspace }';
  }

  @override
  bool get stringify => false;
}
