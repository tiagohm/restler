import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/item_entity.dart';
import 'package:restler/data/entities/multipart_file_entity.dart';

enum MultipartType { text, file }

class MultipartEntity extends Equatable implements ItemEntity {
  @override
  final String uid;
  @override
  final String name;
  @override
  final String value;
  final MultipartFileEntity file;
  @override
  final bool enabled;
  final MultipartType type;

  const MultipartEntity({
    this.uid,
    this.name = '',
    this.value = '',
    this.file = MultipartFileEntity.empty,
    this.enabled = true,
    this.type = MultipartType.text,
  });

  const MultipartEntity.text(
    this.uid,
    this.name,
    this.value, {
    this.enabled = true,
  })  : type = MultipartType.text,
        file = MultipartFileEntity.empty;

  MultipartEntity.file(
    this.uid,
    this.name,
    String filePath,
    String fileName, {
    this.enabled = true,
  })  : file = MultipartFileEntity(path: filePath, name: fileName),
        type = MultipartType.file,
        value = '';

  MultipartEntity.fromJson(Map<String, dynamic> json)
      : file = json['file'] == null
            ? MultipartFileEntity.empty
            : MultipartFileEntity.fromJson(json['file']),
        enabled = json['enabled'],
        type = MultipartType.values[json['type']],
        uid = json['uid'],
        name = json['name'],
        value = json['value'];

  static const empty = MultipartEntity();

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'value': value,
      'file': file?.toJson(),
      'enabled': enabled,
      'type': type.index,
    };
  }

  @override
  MultipartEntity copyWith({
    String uid,
    String name,
    String value,
    MultipartFileEntity file,
    bool enabled,
    MultipartType type,
  }) {
    return MultipartEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      value: value ?? this.value,
      file: file ?? this.file,
      enabled: enabled ?? this.enabled,
      type: type ?? this.type,
    );
  }

  bool get isValid =>
      enabled &&
      name != null &&
      name.isNotEmpty &&
      (type == MultipartType.text || file?.path?.isNotEmpty == true);

  @override
  List get props => [uid, name, value, file, enabled, type];

  @override
  String toString() {
    return 'Multipart { uid: $uid, name: $name, value:$value, enabled: $enabled, file: $file }';
  }
}
