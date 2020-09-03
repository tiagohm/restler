import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/request_auth_entity.dart';
import 'package:restler/data/entities/request_body_entity.dart';
import 'package:restler/data/entities/request_header_entity.dart';
import 'package:restler/data/entities/request_query_entity.dart';
import 'package:restler/data/entities/request_settings_entity.dart';
import 'package:restler/helper.dart';
import 'package:sqler/sqler.dart';

final requestTable = table('request');
final requestUid = col('req_uid');
final requestUrl = col('req_url');
final requestScheme = col('req_scheme');
final requestMethod = col('req_method');
final requestBody = col('req_body');
final requestQuery = col('req_query_data');
final requestHeader = col('req_header_data');
final requestAuth = col('req_auth');
final requestSettings = col('req_settings');
final requestDesc = col('req_description');

class RequestEntity extends Equatable {
  final String uid;
  final String url;
  final String scheme;
  final String method;
  final RequestBodyEntity body;
  final RequestQueryEntity query;
  final RequestHeaderEntity header;
  final RequestAuthEntity auth;
  final RequestSettingsEntity settings;
  final String description;

  const RequestEntity({
    this.uid,
    this.scheme = 'https',
    this.method = 'GET',
    this.url = '',
    this.body = RequestBodyEntity.empty,
    this.query = RequestQueryEntity.empty,
    this.header = RequestHeaderEntity.empty,
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
        scheme: json['scheme'],
        method: json['method'],
        body: RequestBodyEntity.fromJson(json['body']),
        query: RequestQueryEntity.fromJson(json['query']),
        header: RequestHeaderEntity.fromJson(json['header']),
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
      'scheme': scheme,
      'method': method,
      'body': body.toJson(),
      'query': query.toJson(),
      'header': header.toJson(),
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
      scheme: db['req_scheme'],
      method: db['req_method'],
      body: RequestBodyEntity.fromJson(jsonDecode(db['req_body'])),
      query: RequestQueryEntity.fromJson(jsonDecode(db['req_query_data'])),
      header: RequestHeaderEntity.fromJson(jsonDecode(db['req_header_data'])),
      auth: RequestAuthEntity.fromJson(jsonDecode(db['req_auth'])),
      settings: db['req_settings'] == null
          ? RequestSettingsEntity.empty
          : RequestSettingsEntity.fromJson(jsonDecode(db['req_settings'])),
      description: db['req_description'] ?? '',
    );
  }

  Map<String, dynamic> toDatabase() {
    return <String, dynamic>{
      'req_uid': uid,
      'req_url': url,
      'req_scheme': scheme,
      'req_method': method,
      'req_body': jsonEncode(body),
      'req_query_data': jsonEncode(query),
      'req_header_data': jsonEncode(header),
      'req_auth': jsonEncode(auth),
      'req_settings': jsonEncode(settings),
      'req_description': description,
    };
  }

  RequestEntity copyWith({
    String uid,
    String scheme,
    String url,
    String method,
    RequestBodyEntity body,
    RequestQueryEntity query,
    RequestHeaderEntity header,
    RequestAuthEntity auth,
    RequestSettingsEntity settings,
    String description,
  }) {
    return RequestEntity(
      uid: uid ?? this.uid,
      scheme: scheme ?? this.scheme,
      method: method ?? this.method,
      url: url ?? this.url,
      body: body ?? this.body,
      query: query ?? this.query,
      header: header ?? this.header,
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

    return copyWith(
      uid: generateUuid(),
      header: header.copyWith(headers: headers),
      query: query.copyWith(queries: queries),
    );
  }

  String get rightUrl {
    if (scheme != 'auto' &&
        url != null &&
        !url.startsWith('http://') &&
        !url.startsWith('https://')) {
      final realScheme =
          scheme == null ? 'http' : scheme == 'http2' ? 'https' : scheme;
      return '$realScheme://$url';
    } else {
      return url;
    }
  }

  @override
  List<Object> get props => [
        uid,
        scheme,
        method,
        url,
        body,
        query,
        header,
        auth,
        settings,
        description,
      ];

  @override
  String toString() {
    return 'Request { uid: $uid, method: $method, url: $url, body: $body, query: $query,'
        ' header: $header, auth: $auth, settings: $settings, description: $description }';
  }
}
