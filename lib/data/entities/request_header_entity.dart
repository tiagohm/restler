import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/header_entity.dart';

class RequestHeaderEntity extends Equatable {
  final bool enabled;
  final List<HeaderEntity> headers;

  static const empty = RequestHeaderEntity();

  const RequestHeaderEntity({
    this.headers = const [],
    this.enabled = true,
  });

  factory RequestHeaderEntity.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return empty;
    } else {
      return RequestHeaderEntity(
        enabled: json['enabled'],
        headers: (json['data'] as List)
            .map((item) => HeaderEntity.fromJson(item))
            .toList(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'data': headers.map((header) => header.toJson()).toList(),
    };
  }

  RequestHeaderEntity copyWith({
    List<HeaderEntity> headers,
    bool enabled,
  }) {
    return RequestHeaderEntity(
      headers: headers ?? this.headers,
      enabled: enabled ?? this.enabled,
    );
  }

  String get contentType {
    final header = headers.firstWhere(
      (a) => a.name?.toLowerCase() == 'content-type',
      orElse: () => null,
    );
    return header?.value;
  }

  @override
  List get props => [enabled, headers];

  @override
  String toString() {
    return 'RequestHeader { enabled: $enabled, headers: $headers }';
  }
}
