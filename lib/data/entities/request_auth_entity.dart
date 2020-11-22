import 'package:equatable/equatable.dart';
import 'package:restio/restio.dart';

enum RequestAuthType { none, basic, bearer, hawk, digest }

class RequestAuthEntity extends Equatable {
  final RequestAuthType type;
  final bool enabled;

  // Basic. Authorization: Basic {credenciais em base64 no formato username:password}
  final String basicUsername;
  final String basicPassword;

  // Bearer. Authorization: Bearer {token}
  final String bearerToken;
  final String bearerPrefix;

  // Hawk.
  final String hawkId;
  final String hawkKey;
  final String hawkExt;
  final HawkAlgorithm hawkAlgorithm;

  // Digest.
  final String digestUsername;
  final String digestPassword;

  static const empty = RequestAuthEntity();

  const RequestAuthEntity({
    this.type = RequestAuthType.none,
    this.enabled = false,
    this.basicUsername = '',
    this.basicPassword = '',
    this.bearerPrefix = 'Bearer',
    this.bearerToken = '',
    this.hawkId = '',
    this.hawkKey = '',
    this.hawkExt = '',
    this.hawkAlgorithm = HawkAlgorithm.sha256,
    this.digestPassword = '',
    this.digestUsername = '',
  });

  const RequestAuthEntity.basic(
    String username,
    String password, {
    bool enabled = true,
  }) : this(
          type: RequestAuthType.basic,
          enabled: enabled,
          basicUsername: username,
          basicPassword: password,
        );

  const RequestAuthEntity.bearer(
    String token, {
    bool enabled = true,
    String prefix = 'Bearer',
  }) : this(
          type: RequestAuthType.bearer,
          enabled: enabled,
          bearerPrefix: prefix,
          bearerToken: token,
        );

  const RequestAuthEntity.hawk(
    String id,
    String key, {
    String ext,
    bool enabled = true,
    HawkAlgorithm algorithm = HawkAlgorithm.sha256,
  }) : this(
          type: RequestAuthType.hawk,
          enabled: enabled,
          hawkId: id,
          hawkKey: key,
          hawkExt: ext,
          hawkAlgorithm: algorithm,
        );

  const RequestAuthEntity.digest(
    String username,
    String password, {
    bool enabled = true,
  }) : this(
          type: RequestAuthType.digest,
          enabled: enabled,
          digestUsername: username,
          digestPassword: password,
        );

  factory RequestAuthEntity.fromJson(Map<String, dynamic> json) {
    if (json == null || json.isEmpty) {
      return empty;
    } else {
      return RequestAuthEntity(
        type: RequestAuthType.values[json['type']],
        enabled: json['enabled'],
        basicUsername: json['basicUsername'],
        basicPassword: json['basicPassword'],
        digestUsername: json['digestUsername'],
        digestPassword: json['digestPassword'],
        bearerToken: json['bearerToken'],
        bearerPrefix: json['bearerPrefix'],
        hawkId: json['hawkId'],
        hawkKey: json['hawkKey'],
        hawkExt: json['hawkExt'],
        hawkAlgorithm: json['hawkAlgorithm'] == null
            ? HawkAlgorithm.sha256
            : HawkAlgorithm.values[json['hawkAlgorithm']],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type.index,
      'enabled': enabled,
      'basicUsername': basicUsername,
      'basicPassword': basicPassword,
      'digestUsername': digestUsername,
      'digestPassword': digestPassword,
      'bearerToken': bearerToken,
      'bearerPrefix': bearerPrefix,
      'hawkId': hawkId,
      'hawkKey': hawkKey,
      'hawkExt': hawkExt,
      'hawkAlgorithm': hawkAlgorithm.index,
    };
  }

  RequestAuthEntity copyWith({
    RequestAuthType type,
    bool enabled,
    String basicUsername,
    String basicPassword,
    String digestUsername,
    String digestPassword,
    String bearerPrefix,
    String bearerToken,
    String hawkId,
    String hawkKey,
    String hawkExt,
    HawkAlgorithm hawkAlgorithm,
  }) {
    return RequestAuthEntity(
      type: type ?? this.type,
      enabled: enabled ?? this.enabled,
      basicUsername: basicUsername ?? this.basicUsername,
      basicPassword: basicPassword ?? this.basicPassword,
      digestUsername: digestUsername ?? this.digestUsername,
      digestPassword: digestPassword ?? this.digestPassword,
      bearerPrefix: bearerPrefix ?? this.bearerPrefix,
      bearerToken: bearerToken ?? this.bearerToken,
      hawkId: hawkId ?? this.hawkId,
      hawkKey: hawkKey ?? this.hawkKey,
      hawkExt: hawkExt ?? this.hawkExt,
      hawkAlgorithm: hawkAlgorithm ?? this.hawkAlgorithm,
    );
  }

  @override
  List<Object> get props => [
        type,
        enabled,
        basicUsername,
        basicPassword,
        digestUsername,
        digestPassword,
        bearerPrefix,
        bearerToken,
        hawkId,
        hawkKey,
        hawkExt,
        hawkAlgorithm,
      ];

  @override
  String toString() {
    return 'Auth { type: $type, enabled: $enabled, basicUsername: $basicUsername, '
        'basicPassword: $basicPassword, digestUsername: $digestUsername, digestPassword: $digestPassword, '
        'bearerPrefix: $bearerPrefix, bearerToken: $bearerToken, hawkId: $hawkId, hawkKey: $hawkKey, '
        'hawkExt: $hawkExt, hawkAlgorithm: $hawkAlgorithm }';
  }
}
