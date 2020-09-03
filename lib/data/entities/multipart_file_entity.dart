import 'package:equatable/equatable.dart';

class MultipartFileEntity extends Equatable {
  final String path;
  final String name;

  const MultipartFileEntity({
    this.path = '',
    this.name = '',
  });

  static const empty = MultipartFileEntity();

  MultipartFileEntity.fromJson(Map<String, dynamic> json)
      : path = json['path'],
        name = json['name'];

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
    };
  }

  @override
  List get props => [path, name];

  @override
  String toString() {
    return 'File { path: $path, name: $name }';
  }
}
