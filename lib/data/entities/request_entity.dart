import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/request_auth_entity.dart';
import 'package:restler/data/entities/request_body_entity.dart';
import 'package:restler/data/entities/request_data_entity.dart';
import 'package:restler/data/entities/request_target_entity.dart';
import 'package:restler/data/entities/request_header_entity.dart';
import 'package:restler/data/entities/request_notification_entity.dart';
import 'package:restler/data/entities/request_query_entity.dart';
import 'package:restler/data/entities/request_settings_entity.dart';
import 'package:restler/helper.dart';
import 'package:sqler/sqler.dart';

final requestTable = table('request');
final requestUid = col('req_uid');
final requestUrl = col('req_url');
final requestType = col('req_type');
final requestScheme = col('req_scheme');
final requestMethod = col('req_method');
final requestBody = col('req_body');
final requestQuery = col('req_query_data');
final requestHeader = col('req_header_data');
final requestAuth = col('req_auth');
final requestSettings = col('req_settings');
final requestDesc = col('req_description');

const _defaultType = 'rest';

class RequestEntity extends Equatable {
  final String uid;
  final String url;
  final String type;
  final String scheme;
  final String method;
  final RequestBodyEntity body;
  final RequestQueryEntity query;
  final RequestHeaderEntity header;
  final RequestTargetEntity target;
  final RequestDataEntity data;
  final RequestNotificationEntity notification;
  final RequestAuthEntity auth;
  final RequestSettingsEntity settings;
  final String description;

  const RequestEntity({
    this.uid,
    this.type = _defaultType,
    this.scheme = 'https',
    this.method = 'GET',
    this.url = '',
    this.body = RequestBodyEntity.empty,
    this.query = RequestQueryEntity.empty,
    this.header = RequestHeaderEntity.empty,
    this.target = RequestTargetEntity.empty,
    this.data = RequestDataEntity.empty,
    this.notification = RequestNotificationEntity.empty,
    this.auth = RequestAuthEntity.empty,
    this.settings = RequestSettingsEntity.empty,
    this.description = '',
  });

  static const empty = RequestEntity();

  factory RequestEntity.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return empty;
    } else {
      return RequestEntity(
        uid: json['uid'],
        url: json['url'],
        type: json['type'] ?? _defaultType,
        scheme: json['scheme'],
        method: json['method'],
        body: RequestBodyEntity.fromJson(json['body']),
        query: RequestQueryEntity.fromJson(json['query']),
        header: RequestHeaderEntity.fromJson(json['header']),
        target: RequestTargetEntity.fromJson(json['target']),
        data: RequestDataEntity.fromJson(json['data']),
        notification: RequestNotificationEntity.fromJson(json['notification']),
        auth: RequestAuthEntity.fromJson(json['auth']),
        settings: RequestSettingsEntity.fromJson(json['settings']),
        description: json['description'] ?? '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'url': url,
      'type': type,
      'scheme': scheme,
      'method': method,
      'body': body.toJson(),
      'query': query.toJson(),
      'header': header.toJson(),
      'target': target.toJson(),
      'data': data.toJson(),
      'notification': notification.toJson(),
      'auth': auth.toJson(),
      'settings': settings.toJson(),
      'description': description,
    };
  }

  factory RequestEntity.fromDatabase(Map<String, dynamic> db) {
    if (db == null || db['req_uid'] == null) {
      return null;
    }

    return RequestEntity(
      uid: db['req_uid'],
      url: db['req_url'],
      type: db['req_type'] ?? _defaultType,
      scheme: db['req_scheme'],
      method: db['req_method'],
      body: RequestBodyEntity.fromJson(jsonDecode(db['req_body'] ?? '{}')),
      query:
          RequestQueryEntity.fromJson(jsonDecode(db['req_query_data'] ?? '{}')),
      header: RequestHeaderEntity.fromJson(
          jsonDecode(db['req_header_data'] ?? '{}')),
      target: RequestTargetEntity.fromJson(
          jsonDecode(db['req_target_data'] ?? '{}')),
      data: RequestDataEntity.fromJson(jsonDecode(db['req_data_data'] ?? '{}')),
      notification: RequestNotificationEntity.fromJson(
          jsonDecode(db['req_notification_data'] ?? '{}')),
      auth: RequestAuthEntity.fromJson(jsonDecode(db['req_auth'] ?? '{}')),
      settings: db['req_settings'] == null
          ? RequestSettingsEntity.empty
          : RequestSettingsEntity.fromJson(
              jsonDecode(db['req_settings'] ?? '{}')),
      description: db['req_description'] ?? '',
    );
  }

  Map<String, dynamic> toDatabase() {
    return <String, dynamic>{
      'req_uid': uid,
      'req_url': url,
      'req_type': type,
      'req_scheme': scheme,
      'req_method': method,
      'req_body': jsonEncode(body),
      'req_query_data': jsonEncode(query),
      'req_header_data': jsonEncode(header),
      'req_target_data': jsonEncode(target),
      'req_data_data': jsonEncode(data),
      'req_notification_data': jsonEncode(notification),
      'req_auth': jsonEncode(auth),
      'req_description': description,
      'req_settings': jsonEncode(settings),
    };
  }

  RequestEntity copyWith({
    String uid,
    String type,
    String scheme,
    String url,
    String method,
    RequestBodyEntity body,
    RequestQueryEntity query,
    RequestHeaderEntity header,
    RequestTargetEntity target,
    RequestDataEntity data,
    RequestNotificationEntity notification,
    RequestAuthEntity auth,
    RequestSettingsEntity settings,
    String description,
  }) {
    return RequestEntity(
      uid: uid ?? this.uid,
      type: type ?? this.type,
      scheme: scheme ?? this.scheme,
      method: method ?? this.method,
      url: url ?? this.url,
      body: body ?? this.body,
      query: query ?? this.query,
      header: header ?? this.header,
      target: target ?? this.target,
      data: data ?? this.data,
      notification: notification ?? this.notification,
      auth: auth ?? this.auth,
      settings: settings ?? this.settings,
      description: description ?? this.description,
    );
  }

  /// Clona as queries e headers trocando seus UIDs.
  RequestEntity clone() {
    final queries = [
      for (final item in query.queries) item.copyWith(uid: generateUuid()),
    ];

    final headers = [
      for (final item in header.headers) item.copyWith(uid: generateUuid()),
    ];

    final targets = [
      for (final item in target.targets) item.copyWith(uid: generateUuid()),
    ];

    final data = [
      for (final item in this.data.data) item.copyWith(uid: generateUuid()),
    ];

    final notifications = [
      for (final item in notification.notifications)
        item.copyWith(uid: generateUuid()),
    ];

    return copyWith(
      uid: generateUuid(),
      header: header.copyWith(headers: headers),
      query: query.copyWith(queries: queries),
      target: target.copyWith(targets: targets),
      data: this.data.copyWith(data: data),
      notification: notification.copyWith(notifications: notifications),
    );
  }

  String get rightUrl {
    if (scheme != 'auto' &&
        url != null &&
        !url.startsWith('http://') &&
        !url.startsWith('https://')) {
      final realScheme = scheme == null
          ? 'http'
          : scheme == 'http2'
              ? 'https'
              : scheme;
      return '$realScheme://$url';
    } else {
      return url;
    }
  }

  @override
  List<Object> get props => [
        uid,
        type,
        scheme,
        method,
        url,
        body,
        query,
        header,
        target,
        data,
        notification,
        auth,
        settings,
        description,
      ];

  @override
  String toString() {
    return 'Request { uid: $uid, type: $type, method: $method,'
        ' url: $url, body: $body, query: $query, header: $header,'
        ' target: $target, data: $data, notification: $notification,'
        ' auth: $auth, settings: $settings, description: $description }';
  }
}
