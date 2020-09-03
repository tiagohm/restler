import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/item_entity.dart';

class QueryEntity extends Equatable implements ItemEntity {
  @override
  final String uid;
  @override
  final String name;
  @override
  final String value;
  @override
  final bool enabled;

  const QueryEntity({
    this.uid,
    this.name = '',
    this.value = '',
    this.enabled = true,
  });

  static const empty = QueryEntity();

  QueryEntity.fromJson(Map<String, dynamic> json)
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
  QueryEntity copyWith({
    String uid,
    bool enabled,
    String name,
    String value,
  }) {
    return QueryEntity(
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
    return 'Query { uid: $uid, key: $name, value:$value, enabled: $enabled }';
  }
}
