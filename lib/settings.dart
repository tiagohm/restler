import 'dart:io';

import 'package:hive/hive.dart';
import 'package:restio/restio.dart';
import 'package:restler/constants.dart';

class Settings {
  final Box box;

  Settings(this.box);

  static const saveResponseBodyKey = 'settings.response.save';
  static const connectionTimeoutKey = 'settings.request.connectionTimeout';
  static const followRedirectsKey = 'settings.request.followRedirects';
  static const maxRedirectsKey = 'settings.request.maxRedirects';
  static const historyEnabledKey = 'settings.history.enabled';
  static const validateCertificatesKey =
      'settings.request.validateCertificates';
  static const certificateEnabledKey = 'settings.certificate.enabled';
  static const responseBodyFontSizeKey = 'settings.response.fontSize';
  static const darkThemeKey = 'settings.darkTheme';
  static const userAgentKey = 'settings.request.userAgent';
  static const proxyEnabledKey = 'settings.proxy.enabled';
  static const dnsEnabledKey = 'settings.dns.enabled';
  static const cacheEnabledKey = 'settings.cache.enabled';
  static const cookieEnabledKey = 'settings.cookie.enabled';
  static const cacheMaxSizeKey = 'settings.cache.maxSize';
  static const sessionTimeoutKey = 'settings.request.session.timeout';

  bool get saveResponseBody {
    return box.get(saveResponseBodyKey, defaultValue: false);
  }

  set saveResponseBody(bool value) {
    box.put(saveResponseBodyKey, value);
  }

  int get connectionTimeout {
    return box.get(connectionTimeoutKey, defaultValue: 10000);
  }

  set connectionTimeout(int value) {
    box.put(connectionTimeoutKey, value);
  }

  bool get followRedirects {
    return box.get(followRedirectsKey, defaultValue: true);
  }

  set followRedirects(bool value) {
    box.put(followRedirectsKey, value);
  }

  int get maxRedirects {
    return box.get(maxRedirectsKey, defaultValue: 5);
  }

  set maxRedirects(int value) {
    box.put(maxRedirectsKey, value);
  }

  bool get historyEnabled {
    return box.get(historyEnabledKey, defaultValue: true);
  }

  set historyEnabled(bool value) {
    box.put(historyEnabledKey, value);
  }

  bool get validateCertificates {
    return box.get(validateCertificatesKey, defaultValue: false);
  }

  set validateCertificates(bool value) {
    box.put(validateCertificatesKey, value);
  }

  bool get certificateEnabled {
    return box.get(certificateEnabledKey, defaultValue: false);
  }

  set certificateEnabled(bool value) {
    box.put(certificateEnabledKey, value);
  }

  double get responseBodyFontSize {
    return box.get(responseBodyFontSizeKey, defaultValue: 14.0);
  }

  set responseBodyFontSize(double value) {
    box.put(responseBodyFontSizeKey, value);
  }

  bool get darkTheme {
    return box.get(darkThemeKey, defaultValue: true);
  }

  set darkTheme(bool value) {
    box.put(darkThemeKey, value);
  }

  String get userAgent {
    return box.get(
      userAgentKey,
      defaultValue: 'Restler/$appVersion (${Platform.operatingSystem})',
    );
  }

  set userAgent(String value) {
    box.put(userAgentKey, value);
  }

  bool get proxyEnabled {
    return box.get(proxyEnabledKey, defaultValue: false);
  }

  set proxyEnabled(bool value) {
    box.put(proxyEnabledKey, value);
  }

  bool get dnsEnabled {
    return box.get(dnsEnabledKey, defaultValue: false);
  }

  set dnsEnabled(bool value) {
    box.put(dnsEnabledKey, value);
  }

  bool get cacheEnabled {
    return box.get(cacheEnabledKey, defaultValue: false);
  }

  set cacheEnabled(bool value) {
    box.put(cacheEnabledKey, value);
  }

  bool get cookieEnabled {
    return box.get(cookieEnabledKey, defaultValue: true);
  }

  set cookieEnabled(bool value) {
    box.put(cookieEnabledKey, value);
  }

  int get cacheMaxSize {
    return box.get(cacheMaxSizeKey, defaultValue: 10); // 10 MiB
  }

  set cacheMaxSize(int value) {
    box.put(cacheMaxSizeKey, value);
  }

  int get sessionTimeout {
    return box.get(sessionTimeoutKey,
        defaultValue: ConnectionPool.defaultIdleTimeout.inMilliseconds);
  }

  set sessionTimeout(int value) {
    box.put(sessionTimeoutKey, value);
  }
}
