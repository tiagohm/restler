import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
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
  final int cacheSize;
  final int sessionTimeout;

  const SettingsState({
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
    this.cacheSize,
    this.sessionTimeout,
  });

  SettingsState copyWith({
    bool saveResponseBody,
    int connectionTimeout,
    bool followRedirects,
    int maxRedirects,
    bool historyEnabled,
    bool validateCertificates,
    bool certificateEnabled,
    double responseBodyFontSize,
    bool darkTheme,
    String userAgent,
    bool proxyEnabled,
    bool dnsEnabled,
    bool cacheEnabled,
    bool cookieEnabled,
    int cacheMaxSize,
    int cacheSize,
    int sessionTimeout,
  }) {
    return SettingsState(
      saveResponseBody: saveResponseBody ?? this.saveResponseBody,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      historyEnabled: historyEnabled ?? this.historyEnabled,
      validateCertificates: validateCertificates ?? this.validateCertificates,
      certificateEnabled: certificateEnabled ?? this.certificateEnabled,
      responseBodyFontSize: responseBodyFontSize ?? this.responseBodyFontSize,
      darkTheme: darkTheme ?? this.darkTheme,
      userAgent: userAgent ?? this.userAgent,
      proxyEnabled: proxyEnabled ?? this.proxyEnabled,
      dnsEnabled: dnsEnabled ?? this.dnsEnabled,
      cacheEnabled: cacheEnabled ?? this.cacheEnabled,
      cookieEnabled: cookieEnabled ?? this.cookieEnabled,
      cacheMaxSize: cacheMaxSize ?? this.cacheMaxSize,
      cacheSize: cacheSize ?? this.cacheSize,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
    );
  }

  @override
  List<Object> get props => [
        saveResponseBody,
        connectionTimeout,
        followRedirects,
        maxRedirects,
        historyEnabled,
        validateCertificates,
        certificateEnabled,
        responseBodyFontSize,
        darkTheme,
        userAgent,
        proxyEnabled,
        dnsEnabled,
        cacheEnabled,
        cookieEnabled,
        cacheMaxSize,
        cacheSize,
        sessionTimeout,
      ];
}
