import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/target_entity.dart';

class RequestTargetEntity extends Equatable {
  final bool enabled;
  final List<TargetEntity> targets;

  static const empty = RequestTargetEntity();

  const RequestTargetEntity({
    this.targets = const [],
    this.enabled = true,
  });

  factory RequestTargetEntity.fromJson(Map<String, dynamic> json) {
    if (json == null || json.isEmpty) {
      return empty;
    } else {
      return RequestTargetEntity(
        enabled: json['enabled'],
        targets: (json['targets'] as List)
            .map((item) => TargetEntity.fromJson(item))
            .toList(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'targets': targets.map((target) => target.toJson()).toList()
    };
  }

  RequestTargetEntity copyWith({
    List<TargetEntity> targets,
    bool enabled,
  }) {
    return RequestTargetEntity(
      targets: targets ?? this.targets,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List get props => [enabled, targets];

  @override
  String toString() {
    return 'RequestTarget { enabled: $enabled, targets: $targets }';
  }
}
