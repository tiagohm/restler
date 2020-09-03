import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/item_entity.dart';

class FormEntity extends Equatable implements ItemEntity {
  @override
  final String uid;
  @override
  final String name;
  @override
  final String value;
  @override
  final bool enabled;

  const FormEntity({
    this.uid,
    this.name = '',
    this.value = '',
    this.enabled = true,
  });

  FormEntity.fromJson(Map<String, dynamic> json)
      : enabled = json['enabled'],
        uid = json['uid'],
        name = json['name'],
        value = json['value'];

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'value': value,
      'enabled': enabled,
    };
  }

  @override
  FormEntity copyWith({
    String uid,
    String name,
    String value,
    bool enabled,
  }) {
    return FormEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      value: value ?? this.value,
      enabled: enabled ?? this.enabled,
    );
  }

  bool get isValid => enabled && name != null && name.isNotEmpty;

  @override
  List get props => [uid, name, value, enabled];

  @override
  String toString() {
    return 'Form { uid: $uid, name: $name, value:$value, enabled: $enabled }';
  }
}
