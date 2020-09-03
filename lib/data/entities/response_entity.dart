import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:restio/restio.dart';
import 'package:restler/data/entities/cookie_entity.dart';
import 'package:restler/data/entities/header_entity.dart';
import 'package:restler/data/entities/redirect_entity.dart';
import 'package:restler/helper.dart';
import 'package:sqler/sqler.dart';

final responseTable = table('response');
final responseUid = col('resp_uid');
final responseStatus = col('resp_status');
final responseTime = col('resp_time');
final responseContentType = col('resp_content_type');
final responseData = col('resp_data');
final responseHeaders = col('resp_headers');
final responseCookies = col('resp_cookies');
final responseRedirects = col('resp_redirects');
final responseDataSize = col('resp_data_size');

class ResponseEntity extends Equatable {
  final String uid;
  final int status;
  final int time;
  final MediaType contentType;
  final List<int> data;
  final List<HeaderEntity> headers;
  final List<CookieEntity> cookies;
  final List<RedirectEntity> redirects;
  final int size;
  final bool cache;

  const ResponseEntity({
    this.uid,
    this.status = 0,
    this.time = 0,
    this.contentType = MediaType.octetStream,
    this.data = const [],
    this.size = 0,
    this.headers = const [],
    this.cookies = const [],
    this.redirects = const [],
    this.cache = false,
  });

  static const empty = ResponseEntity();

  bool get isVisual => contentType?.type == 'image';

  bool get isSourceCode => !isVisual;

  bool get isJson => contentType?.subType == 'json';

  bool get isXml =>
      contentType?.subType == 'xml' ||
      contentType?.subType?.endsWith('+xml') == true;

  bool get isHighlighted => isJson || isXml;

  factory ResponseEntity.fromDatabase(
    Map<String, dynamic> db, {
    bool fetchBody = false,
  }) {
    if (db == null || db['resp_uid'] == null) {
      return ResponseEntity.empty;
    }

    final _data =
        !fetchBody ? const <int>[] : decompress(db['resp_data'] as String);

    final _length = !fetchBody ? db['resp_data_size'] ?? 0 : _data.length;

    var _contentType = MediaType.text;

    try {
      _contentType =
          db['resp_content_type'] == null || db['resp_content_type'].isEmpty
              ? null
              : MediaType.parse(db['resp_content_type']);
    } catch (e) {
      // nada.
    }

    final respHeaders = db['resp_headers'];
    final _headers = respHeaders == null
        ? const <HeaderEntity>[]
        : (jsonDecode(respHeaders) as List)
            .map((item) => HeaderEntity.fromJson(item))
            .toList();

    final respCookies = db['resp_cookies'];
    final _cookies = respCookies == null
        ? const <CookieEntity>[]
        : (jsonDecode(respCookies) as List)
            .map((item) => CookieEntity.fromJson(item))
            .toList();

    final respRedirects = db['resp_redirects'];
    final _redirets = respRedirects == null
        ? const <RedirectEntity>[]
        : (jsonDecode(respRedirects) as List)
            .map((item) => RedirectEntity.fromJson(item))
            .toList();

    return ResponseEntity(
      uid: db['resp_uid'],
      status: db['resp_status'],
      time: db['resp_time'],
      contentType: _contentType,
      data: _data,
      size: _length,
      headers: _headers,
      cookies: _cookies,
      redirects: _redirets,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'resp_uid': uid,
      'resp_status': status,
      'resp_time': time,
      'resp_content_type': contentType?.value,
      'resp_data_size': size ?? 0,
      'resp_data': compress(data),
      'resp_headers': jsonEncode(headers),
      'resp_cookies': jsonEncode(cookies),
      'resp_redirects': jsonEncode(redirects),
    };
  }

  ResponseEntity copyWith({
    String uid,
    int status,
    int time,
    MediaType contentType,
    List<int> data,
    int size,
    List<HeaderEntity> headers,
    List<CookieEntity> cookies,
    List<RedirectEntity> redirects,
    bool cache,
  }) {
    return ResponseEntity(
      uid: uid ?? this.uid,
      status: status ?? this.status,
      time: time ?? this.time,
      contentType: contentType ?? this.contentType,
      data: data ?? this.data,
      size: size ?? this.size,
      headers: headers ?? this.headers,
      cookies: cookies ?? this.cookies,
      redirects: redirects ?? this.redirects,
      cache: cache ?? this.cache,
    );
  }

  @override
  List get props => [
        uid,
        status,
        time,
        contentType,
        data,
        headers,
        cookies,
        redirects,
        cache,
      ];

  @override
  String toString() {
    return 'ResponseEntity { uid: $uid, status: $status, time: $time, contentType: $contentType,'
        ' size: $size, headers: $headers, cookies: $cookies, redirects: $redirects }';
  }
}
