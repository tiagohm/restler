import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/query_entity.dart';

class RequestQueryEntity extends Equatable {
  final bool enabled;
  final List<QueryEntity> queries;

  static const empty = RequestQueryEntity();

  const RequestQueryEntity({
    this.queries = const [],
    this.enabled = true,
  });

  factory RequestQueryEntity.fromJson(Map<String, dynamic> json) {
    if (json == null || json.isEmpty) {
      return empty;
    } else {
      return RequestQueryEntity(
        enabled: json['enabled'],
        queries: (json['data'] as List)
            .map((item) => QueryEntity.fromJson(item))
            .toList(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'data': queries.map((query) => query.toJson()).toList()
    };
  }

  RequestQueryEntity copyWith({
    List<QueryEntity> queries,
    bool enabled,
  }) {
    return RequestQueryEntity(
      queries: queries ?? this.queries,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List get props => [enabled, queries];

  @override
  String toString() {
    return 'RequestQuery { enabled: $enabled, queries: $queries }';
  }
}
