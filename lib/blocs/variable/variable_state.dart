import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/variable_entity.dart';

class VariableState extends Equatable {
  final List<VariableEntity> data;
  final bool search;
  final String searchText;

  const VariableState({
    this.data = const [],
    this.search = false,
    this.searchText = '',
  });

  VariableState copyWith({
    List<VariableEntity> data,
    bool search,
    String searchText,
  }) {
    return VariableState(
      data: data ?? this.data,
      search: search ?? this.search,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List get props => [data, search, searchText];
}
