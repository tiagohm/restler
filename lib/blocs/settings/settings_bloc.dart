import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:restio/restio.dart';
import 'package:restler/blocs/settings/settings_event.dart';
import 'package:restler/blocs/settings/settings_state.dart';
import 'package:restler/inject.dart';
import 'package:restler/settings.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final Settings settings;

  SettingsBloc(this.settings)
      : super(
          SettingsState(
            saveResponseBody: settings.saveResponseBody,
            connectionTimeout: settings.connectionTimeout,
            followRedirects: settings.followRedirects,
            maxRedirects: settings.maxRedirects,
            historyEnabled: settings.historyEnabled,
            validateCertificates: settings.validateCertificates,
            certificateEnabled: settings.certificateEnabled,
            responseBodyFontSize: settings.responseBodyFontSize,
            darkTheme: settings.darkTheme,
            userAgent: settings.userAgent,
            proxyEnabled: settings.proxyEnabled,
            dnsEnabled: settings.dnsEnabled,
            cacheEnabled: settings.cacheEnabled,
            cookieEnabled: settings.cookieEnabled,
            cacheMaxSize: settings.cacheMaxSize,
            cacheSize: 0,
            sessionTimeout: settings.sessionTimeout,
          ),
        );

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    if (event is SettingsStarted) {
      yield* _mapSettingsStartedToState();
    } else if (event is SettingsEdited) {
      yield* _mapSettingsEditedToState(event);
    } else if (event is CacheCleared) {
      yield* _mapCacheClearedToState();
    }
  }

  Stream<SettingsState> _mapSettingsStartedToState() async* {
    yield state.copyWith(cacheSize: await kiwi<CacheStore>().size());
  }

  Stream<SettingsState> _mapSettingsEditedToState(
    SettingsEdited event,
  ) async* {
    if (event.connectionTimeout != null) {
      settings.connectionTimeout = event.connectionTimeout;
    }

    if (event.saveResponseBody != null) {
      settings.saveResponseBody = event.saveResponseBody;
    }

    if (event.followRedirects != null) {
      settings.followRedirects = event.followRedirects;
    }

    if (event.maxRedirects != null) {
      settings.maxRedirects = event.maxRedirects;
    }

    if (event.historyEnabled != null) {
      settings.historyEnabled = event.historyEnabled;
    }

    if (event.validateCertificates != null) {
      settings.validateCertificates = event.validateCertificates;
    }

    if (event.certificateEnabled != null) {
      settings.certificateEnabled = event.certificateEnabled;
    }

    if (event.responseBodyFontSize != null) {
      settings.responseBodyFontSize = event.responseBodyFontSize;
    }

    if (event.darkTheme != null) {
      settings.darkTheme = event.darkTheme;
    }

    if (event.userAgent != null) {
      settings.userAgent = event.userAgent;
    }

    if (event.proxyEnabled != null) {
      settings.proxyEnabled = event.proxyEnabled;
    }

    if (event.dnsEnabled != null) {
      settings.dnsEnabled = event.dnsEnabled;
    }

    if (event.cacheEnabled != null) {
      settings.cacheEnabled = event.cacheEnabled;
    }

    if (event.cookieEnabled != null) {
      settings.cookieEnabled = event.cookieEnabled;
    }

    final cacheStore = kiwi<CacheStore>();

    if (event.cacheMaxSize != null) {
      settings.cacheMaxSize = event.cacheMaxSize;
      await cacheStore.setMaxSize(event.cacheMaxSize * 1024 * 1024);
    }

    final connectionPool = kiwi<ConnectionPool>();

    if (event.sessionTimeout != null) {
      settings.sessionTimeout = event.sessionTimeout;

      if (event.sessionTimeout >= 0) {
        connectionPool.idleTimeout =
            Duration(milliseconds: event.sessionTimeout);
      }
    }

    yield state.copyWith(
      connectionTimeout: event.connectionTimeout,
      saveResponseBody: event.saveResponseBody,
      followRedirects: event.followRedirects,
      maxRedirects: event.maxRedirects,
      historyEnabled: event.historyEnabled,
      validateCertificates: event.validateCertificates,
      certificateEnabled: event.certificateEnabled,
      responseBodyFontSize: event.responseBodyFontSize,
      darkTheme: event.darkTheme,
      userAgent: event.userAgent,
      proxyEnabled: event.proxyEnabled,
      dnsEnabled: event.dnsEnabled,
      cacheEnabled: event.cacheEnabled,
      cookieEnabled: event.cookieEnabled,
      cacheMaxSize: event.cacheMaxSize,
      cacheSize: await cacheStore.size(),
      sessionTimeout: connectionPool.idleTimeout.inMilliseconds,
    );
  }

  Stream<SettingsState> _mapCacheClearedToState() async* {
    final cacheStore = kiwi<CacheStore>();
    await cacheStore.clear();
    yield state.copyWith(cacheSize: await cacheStore.size());
  }
}
