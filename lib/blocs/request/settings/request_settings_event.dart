import 'package:restler/data/entities/dns_entity.dart';
import 'package:restler/data/entities/proxy_entity.dart';
import 'package:restler/data/entities/request_settings_entity.dart';

abstract class RequestSettingsEvent {}

class Started extends RequestSettingsEvent {
  final RequestSettingsEntity settings;

  Started(this.settings);
}

class RequestSettingsChanged extends RequestSettingsEvent {
  final ProxyEntity proxy;
  final DnsEntity dns;
  final bool sendCookies;
  final bool storeCookies;
  final bool cache;
  final bool enableVariables;
  final bool keepEqualSign;
  final bool persistentConnection;

  RequestSettingsChanged({
    this.proxy,
    this.dns,
    this.sendCookies,
    this.storeCookies,
    this.cache,
    this.enableVariables,
    this.keepEqualSign,
    this.persistentConnection,
  });
}
