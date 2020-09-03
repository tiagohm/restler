import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/helper.dart';
import 'package:sqler/sqler.dart';

final cookieTable = table('cookie');
final cookieUid = col('cook_uid');
final cookieName = col('cook_name');
final cookieValue = col('cook_value');
final cookieExpires = col('cook_expires');
final cookieMaxAge = col('cook_max_age');
final cookieDomain = col('cook_domain');
final cookiePath = col('cook_path');
final cookieSecure = col('cook_secure');
final cookieHttpOnly = col('cook_http_only');
final cookieTimestamp = col('cook_ts');
final cookieEnabled = col('cook_enabled');
final cookieWorkspace = col('cook_workspace');

class CookieEntity extends Equatable {
  final String uid;
  final String name;
  final String value;
  final DateTime expires;
  final int maxAge;
  final String domain;
  final String path;
  final bool secure;
  final bool httpOnly;
  final int timestamp;
  final bool enabled;
  final WorkspaceEntity workspace;

  const CookieEntity({
    this.uid,
    this.timestamp,
    this.enabled = true,
    this.name,
    this.value,
    this.expires,
    this.maxAge,
    this.domain,
    this.path = '/',
    this.secure = false,
    this.httpOnly = false,
    this.workspace = WorkspaceEntity.empty,
  });

  CookieEntity.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        timestamp = json['ts'],
        enabled = json['enabled'] ?? true,
        name = json['name'],
        value = json['value'],
        expires = json['expires'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(json['expires'], isUtc: true),
        maxAge = json['maxAge'],
        domain = json['domain'],
        path = json['path'],
        secure = json['secure'],
        httpOnly = json['httpOnly'],
        workspace = WorkspaceEntity.fromJson(json['workspace']);

  CookieEntity.fromDatabase(Map<String, dynamic> db)
      : uid = db['cook_uid'],
        timestamp = db['cook_ts'],
        enabled = db['cook_enabled'] != 0,
        name = db['cook_name'],
        value = db['cook_value'],
        expires = db['cook_expires'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                db['cook_expires'],
                isUtc: true,
              ),
        maxAge = db['cook_max_age'],
        domain = db['cook_domain'],
        path = db['cook_path'],
        secure = db['cook_secure'] == 1,
        httpOnly = db['cook_http_only'] == 1,
        workspace = WorkspaceEntity.fromDatabase(db);

  Map<String, dynamic> toDatabase() {
    return {
      'cook_uid': uid,
      'cook_enabled': enabled ? 1 : 0,
      'cook_domain': domain,
      'cook_ts': timestamp,
      'cook_path': path,
      'cook_name': name,
      'cook_value': value,
      'cook_expires': expires?.millisecondsSinceEpoch,
      'cook_max_age': maxAge,
      'cook_secure': secure ? 1 : 0,
      'cook_http_only': httpOnly ? 1 : 0,
      'cook_workspace': workspace?.uid,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'value': value,
      'expires': expires?.millisecondsSinceEpoch,
      'maxAge': maxAge,
      'domain': domain,
      'path': path,
      'secure': secure,
      'httpOnly': httpOnly,
      'ts': timestamp,
      'workspace': workspace?.toJson(),
    };
  }

  bool get expired {
    // Fazer comparações usando UTC.
    final now = currentUtc();
    // Max-Age tem prioridade.
    if (maxAge != null && maxAge >= 0) {
      if (maxAge == 0) {
        return true;
      }

      final expiresDate = DateTime.fromMillisecondsSinceEpoch(
        timestamp + maxAge * 1000,
        isUtc: true,
      );

      return now.isAfter(expiresDate);
    }
    // Depois, o expires.
    else if (expires != null && expires.millisecondsSinceEpoch >= 0) {
      if (expires.millisecondsSinceEpoch == 0) {
        return true;
      }

      final expiresDate = expires.toUtc();

      return now.isAfter(expiresDate);
    }

    // Tempo ilimitado ou até encerrar a sessão.
    return false;
  }

  String get expiresAsString => expires.millisecondsSinceEpoch > 0
      ? HttpDate.format(expires.toUtc())
      : '';

  CookieEntity copyWith({
    String uid,
    int timestamp,
    bool enabled,
    String name,
    String value,
    DateTime expires,
    int maxAge,
    String domain,
    String path,
    bool secure,
    bool httpOnly,
    WorkspaceEntity workspace,
  }) {
    return CookieEntity(
      uid: uid ?? this.uid,
      timestamp: timestamp ?? this.timestamp,
      enabled: enabled ?? this.enabled,
      name: name ?? this.name,
      value: value ?? this.value,
      expires: expires ?? this.expires,
      maxAge: maxAge ?? this.maxAge,
      domain: domain ?? this.domain,
      path: path ?? this.path,
      secure: secure ?? this.secure,
      httpOnly: httpOnly ?? this.httpOnly,
      workspace: workspace ?? this.workspace,
    );
  }

  String toCookieString() {
    final sb = StringBuffer();
    sb..write(name)..write('=')..write(value);

    if (expires != null && expires.millisecondsSinceEpoch > 0) {
      sb..write('; Expires=')..write(expiresAsString);
    }

    if (maxAge != null) {
      sb..write('; Max-Age=')..write(maxAge);
    }

    if (domain != null) {
      sb..write('; Domain=')..write(domain);
    }

    if (path != null) {
      sb..write('; Path=')..write(path);
    }

    if (secure) {
      sb.write('; Secure');
    }

    if (httpOnly) {
      sb.write('; HttpOnly');
    }

    return sb.toString();
  }

  @override
  String toString() {
    return 'Cookie { uid: $uid, timestamp: $timestamp, enabled: $enabled, name: $name,'
        'value: $value, expires: $expires, maxAge: $maxAge, domain: $domain, path: $path,'
        ' secure: $secure, httpOnly: $httpOnly, workspace: $workspace }';
  }

  @override
  List get props => [
        uid,
        timestamp,
        enabled,
        name,
        value,
        expires,
        maxAge,
        domain,
        path,
        secure,
        httpOnly,
        workspace,
      ];
}
