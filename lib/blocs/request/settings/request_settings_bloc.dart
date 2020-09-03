import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:restler/blocs/request/settings/request_settings_event.dart';
import 'package:restler/blocs/request/settings/request_settings_state.dart';
import 'package:restler/data/entities/dns_entity.dart';
import 'package:restler/data/entities/proxy_entity.dart';
import 'package:restler/data/repositories/dns_repository.dart';
import 'package:restler/data/repositories/proxy_repository.dart';
import 'package:restler/data/repositories/workspace_repository.dart';
import 'package:restler/inject.dart';

class RequestSettingsBloc
    extends Bloc<RequestSettingsEvent, RequestSettingsState> {
  final _proxyRepository = kiwi<ProxyRepository>();
  final _dnsRepository = kiwi<DnsRepository>();
  final _workspaceRepository = kiwi<WorkspaceRepository>();

  RequestSettingsBloc() : super(const RequestSettingsState());

  @override
  Stream<RequestSettingsState> mapEventToState(
    RequestSettingsEvent event,
  ) async* {
    if (event is Started) {
      yield* _mapStartedToState(event);
    } else if (event is RequestSettingsChanged) {
      yield* _mapRequestSettingsChangedToState(event);
    }
  }

  Stream<RequestSettingsState> _mapStartedToState(Started event) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    // Verificar se está apontando para um proxy deletado.
    final proxy = await _proxyRepository.get(event.settings.proxy?.uid) ??
        ProxyEntity.empty;

    // Verificar se está apontando para um DNS deletado.
    final dns =
        await _dnsRepository.get(event.settings.dns?.uid) ?? DnsEntity.empty;

    yield state.copyWith(
      proxies: [
        ProxyEntity.empty,
        ...await _proxyRepository.all(workspace),
      ],
      dnss: [
        DnsEntity.empty,
        ...await _dnsRepository.all(workspace),
      ],
      settings: event.settings.copyWith(
        proxy: proxy,
        dns: dns,
      ),
    );
  }

  Stream<RequestSettingsState> _mapRequestSettingsChangedToState(
    RequestSettingsChanged event,
  ) async* {
    yield state.copyWith(
      settings: state.settings.copyWith(
        proxy: event.proxy,
        dns: event.dns,
        sendCookies: event.sendCookies,
        storeCookies: event.storeCookies,
        cache: event.cache,
        enableVariables: event.enableVariables,
        keepEqualSign: event.keepEqualSign,
        persistentConnection: event.persistentConnection,
      ),
    );
  }
}
