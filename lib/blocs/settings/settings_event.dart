abstract class SettingsEvent {}

class SettingsStarted extends SettingsEvent {}

class CacheCleared extends SettingsEvent {}

class SettingsEdited extends SettingsEvent {
  final bool saveResponseBody;
  final int connectionTimeout;
  final bool followRedirects;
  final int maxRedirects;
  final bool historyEnabled;
  final bool validateCertificates;
  final bool certificateEnabled;
  final double responseBodyFontSize;
  final bool darkTheme;
  final String userAgent;
  final bool proxyEnabled;
  final bool dnsEnabled;
  final bool cacheEnabled;
  final bool cookieEnabled;
  final int cacheMaxSize;
  final int sessionTimeout;

  SettingsEdited({
    this.saveResponseBody,
    this.connectionTimeout,
    this.followRedirects,
    this.maxRedirects,
    this.historyEnabled,
    this.validateCertificates,
    this.certificateEnabled,
    this.responseBodyFontSize,
    this.darkTheme,
    this.userAgent,
    this.proxyEnabled,
    this.dnsEnabled,
    this.cacheEnabled,
    this.cookieEnabled,
    this.cacheMaxSize,
    this.sessionTimeout,
  });
}
