import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/data_entity.dart';

class RequestDataEntity extends Equatable {
  final bool enabled;
  final List<DataEntity> data;

  static const empty = RequestDataEntity();

  const RequestDataEntity({
    this.data = const [],
    this.enabled = true,
  });

  factory RequestDataEntity.fromJson(Map<String, dynamic> json) {
    if (json == null || json.isEmpty) {
      return empty;
    } else {
      return RequestDataEntity(
        enabled: json['enabled'],
        data: (json['data'] as List)
            .map((item) => DataEntity.fromJson(item))
            .toList(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'data': data.map((data) => data.toJson()).toList()
    };
  }

  RequestDataEntity copyWith({
    List<DataEntity> data,
    bool enabled,
  }) {
    return RequestDataEntity(
      data: data ?? this.data,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List get props => [enabled, data];

  @override
  String toString() {
    return 'RequestData { enabled: $enabled, data: $data }';
  }
}
