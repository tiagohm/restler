import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/item_entity.dart';

class TargetEntity extends Equatable implements ItemEntity {
  @override
  final String uid;
  @override
  final String name;
  @override
  final String value;
  @override
  final bool enabled;

  const TargetEntity({
    this.uid,
    this.name = 'to',
    this.value = '',
    this.enabled = true,
  });

  static const empty = TargetEntity();

  TargetEntity.fromJson(Map<String, dynamic> json)
      : enabled = json['enabled'],
        uid = json['uid'],
        name = json['key'],
        value = json['value'];

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'enabled': enabled,
      'key': name,
      'value': value,
    };
  }

  @override
  TargetEntity copyWith({
    String uid,
    bool enabled,
    String name,
    String value,
  }) {
    return TargetEntity(
      uid: uid ?? this.uid,
      enabled: enabled ?? this.enabled,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  bool get isValid =>
      enabled &&
      name != null &&
      name.isNotEmpty &&
      value != null &&
      value.isNotEmpty;

  @override
  List get props => [uid, enabled, name, value];

  @override
  String toString() {
    return 'Target { uid: $uid, key: $name, value:$value, enabled: $enabled }';
  }
}
