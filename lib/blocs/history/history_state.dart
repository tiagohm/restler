import 'package:equatable/equatable.dart';
import 'package:restler/blocs/history/sort.dart';
import 'package:restler/data/entities/history_entity.dart';

class HistoryState extends Equatable {
  final List<HistoryEntity> data;
  final bool search;
  final String searchText;
  final Sort sort;

  const HistoryState({
    this.data = const [],
    this.search = false,
    this.searchText = '',
    this.sort = Sort.empty,
  });

  HistoryState copyWith({
    List<HistoryEntity> data,
    bool search,
    String searchText,
    Sort sort,
  }) {
    return HistoryState(
      data: data ?? this.data,
      search: search ?? this.search,
      searchText: searchText ?? this.searchText,
      sort: sort ?? this.sort,
    );
  }

  @override
  List get props => [data, search, searchText, sort];
}
