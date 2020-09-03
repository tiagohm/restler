import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/dns_entity.dart';
import 'package:restler/data/entities/proxy_entity.dart';
import 'package:restler/data/entities/request_settings_entity.dart';

class RequestSettingsState extends Equatable {
  final List<ProxyEntity> proxies;
  final List<DnsEntity> dnss;
  final RequestSettingsEntity settings;

  const RequestSettingsState({
    this.proxies = const [ProxyEntity.empty],
    this.dnss = const [DnsEntity.empty],
    this.settings = RequestSettingsEntity.empty,
  });

  RequestSettingsState copyWith({
    List<ProxyEntity> proxies,
    List<DnsEntity> dnss,
    RequestSettingsEntity settings,
  }) {
    return RequestSettingsState(
      proxies: proxies ?? this.proxies,
      dnss: dnss ?? this.dnss,
      settings: settings ?? this.settings,
    );
  }

  @override
  List get props => [proxies, dnss, settings];
}
