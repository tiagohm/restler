import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/dns_entity.dart';
import 'package:restler/data/entities/proxy_entity.dart';

class RequestSettingsEntity extends Equatable {
  final ProxyEntity proxy;
  final DnsEntity dns;
  final bool sendCookies;
  final bool storeCookies;
  final bool cache;
  final bool enableVariables;
  final bool keepEqualSign;
  final bool persistentConnection;

  const RequestSettingsEntity({
    this.proxy = ProxyEntity.empty,
    this.dns = DnsEntity.empty,
    this.sendCookies = true,
    this.storeCookies = true,
    this.cache = true,
    this.enableVariables = true,
    this.keepEqualSign = false,
    this.persistentConnection = true,
  });

  static const empty = RequestSettingsEntity();

  factory RequestSettingsEntity.fromJson(Map<String, dynamic> json) {
    if (json == null || json.isEmpty || json['proxy'] is! Map) {
      return RequestSettingsEntity.empty;
    } else {
      return RequestSettingsEntity(
        proxy: ProxyEntity.fromJson(json['proxy']),
        dns: DnsEntity.fromJson(json['dns']),
        sendCookies: json['sendCookies'] ?? true,
        storeCookies: json['storeCookies'] ?? true,
        cache: json['cache'] ?? true,
        enableVariables: json['enableVariables'] ?? true,
        keepEqualSign: json['keepEqualSign'] ?? false,
        persistentConnection: json['persistentConnection'] ?? true,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'proxy': proxy?.toJson(),
      'dns': dns?.toJson(),
      'sendCookies': sendCookies ?? true,
      'storeCookies': storeCookies ?? true,
      'cache': cache ?? true,
      'enableVariables': enableVariables ?? true,
      'keepEqualSign': keepEqualSign ?? false,
      'persistentConnection': persistentConnection ?? true,
    };
  }

  RequestSettingsEntity copyWith({
    ProxyEntity proxy,
    DnsEntity dns,
    bool sendCookies,
    bool storeCookies,
    bool cache,
    bool enableVariables,
    bool keepEqualSign,
    bool persistentConnection,
  }) {
    return RequestSettingsEntity(
      proxy: proxy ?? this.proxy,
      dns: dns ?? this.dns,
      sendCookies: sendCookies ?? this.sendCookies,
      storeCookies: storeCookies ?? this.storeCookies,
      cache: cache ?? this.cache,
      enableVariables: enableVariables ?? this.enableVariables,
      keepEqualSign: keepEqualSign ?? this.keepEqualSign,
      persistentConnection: persistentConnection ?? this.persistentConnection,
    );
  }

  @override
  List get props => [
        proxy,
        dns,
        sendCookies,
        storeCookies,
        cache,
        enableVariables,
        keepEqualSign,
        persistentConnection,
      ];

  @override
  String toString() {
    return 'Settings { proxy: $proxy, dns: $dns, sendCookies: $sendCookies, storeCookies: $storeCookies,'
        ' cache: $cache, enableVariables: $enableVariables, keepEqualSign: $keepEqualSign,'
        ' persistentConnection: $persistentConnection }';
  }
}
