import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/form_entity.dart';
import 'package:restler/data/entities/multipart_entity.dart';

enum RequestBodyType { multipart, form, text, file, none }

class RequestBodyEntity extends Equatable {
  final bool enabled;
  final RequestBodyType type;
  final String text;
  final List<FormEntity> formItems;
  final List<MultipartEntity> multipartItems;
  final String file;

  const RequestBodyEntity({
    this.enabled = true,
    this.type = RequestBodyType.none,
    this.text = '',
    this.formItems = const [],
    this.multipartItems = const [],
    this.file = '',
  });

  static const empty = RequestBodyEntity();

  factory RequestBodyEntity.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return empty;
    } else {
      return RequestBodyEntity(
        enabled: json['enabled'],
        type: RequestBodyType.values[json['type']],
        text: json['text'],
        formItems: (json['formItems'] as List)
                ?.map((item) => FormEntity.fromJson(item))
                ?.toList() ??
            [],
        multipartItems: (json['multipartItems'] as List)
                ?.map((item) => MultipartEntity.fromJson(item))
                ?.toList() ??
            [],
        file: json['file'] == null
            ? ''
            : json['file'] is bool ? '' : json['file'],
      );
    }
  }

  const RequestBodyEntity.text(String text)
      : this(type: RequestBodyType.text, text: text);

  const RequestBodyEntity.file(String filepath)
      : this(type: RequestBodyType.file, file: filepath);

  const RequestBodyEntity.multipart(List<MultipartEntity> multipartItems)
      : this(
          type: RequestBodyType.multipart,
          multipartItems: multipartItems,
        );

  const RequestBodyEntity.form(List<FormEntity> formItems)
      : this(
          type: RequestBodyType.form,
          formItems: formItems,
        );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'enabled': enabled,
      'type': type.index,
      'text': text,
      'formItems': formItems.map((item) => item.toJson()).toList(),
      'multipartItems': multipartItems.map((item) => item.toJson()).toList(),
      'file': file,
    };
  }

  RequestBodyEntity copyWith({
    bool enabled,
    RequestBodyType type,
    String text,
    List<FormEntity> formItems,
    List<MultipartEntity> multipartItems,
    String file,
  }) {
    return RequestBodyEntity(
      enabled: enabled ?? this.enabled,
      type: type ?? this.type,
      text: text ?? this.text,
      formItems: formItems ?? this.formItems,
      multipartItems: multipartItems ?? this.multipartItems,
      file: file ?? this.file,
    );
  }

  @override
  List<Object> get props =>
      [enabled, type, text, formItems, multipartItems, file];

  @override
  String toString() {
    return 'Body { enabled: $enabled, type: $type, text: $text, formItems: $formItems, '
        ' multipartItems: $multipartItems, file: $file }';
  }
}
