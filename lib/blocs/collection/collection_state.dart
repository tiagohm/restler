import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/folder_entity.dart';

class CollectionState extends Equatable {
  final List data;
  final FolderEntity folder;
  final String searchText;
  final bool search;

  const CollectionState({
    this.data = const [],
    this.folder = FolderEntity.root,
    this.searchText = '',
    this.search = false,
  });

  CollectionState copyWith({
    List data,
    FolderEntity folder,
    String searchText,
    bool search,
  }) {
    return CollectionState(
      data: data ?? this.data,
      folder: folder ?? this.folder,
      searchText: searchText ?? this.searchText,
      search: search ?? this.search,
    );
  }

  @override
  List<Object> get props => [data, folder, searchText, search];
}
