import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/item_entity.dart';

class HeaderEntity extends Equatable implements ItemEntity {
  @override
  final String uid;
  @override
  final String name;
  @override
  final String value;
  @override
  final bool enabled;

  const HeaderEntity({
    this.uid,
    this.name = '',
    this.value = '',
    this.enabled = true,
  });

  static const empty = HeaderEntity();

  HeaderEntity.fromJson(Map<String, dynamic> json)
      : enabled = json['enabled'],
        uid = json['uid'],
        name = json['name'],
        value = json['value'];

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'enabled': enabled,
      'name': name,
      'value': value,
    };
  }

  @override
  HeaderEntity copyWith({
    String uid,
    bool enabled,
    String name,
    String value,
  }) {
    return HeaderEntity(
      uid: uid ?? this.uid,
      enabled: enabled ?? this.enabled,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  bool get isValid => enabled && name != null && name.isNotEmpty;

  @override
  List get props => [uid, enabled, name, value];

  @override
  String toString() {
    return 'Header { uid: $uid, name: $name, value:$value, enabled: $enabled }';
  }
}
