import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/environment_entity.dart';

class EnvironmentState extends Equatable {
  final List<EnvironmentEntity> data;
  final bool search;
  final String searchText;

  const EnvironmentState({
    this.data = const [],
    this.search = false,
    this.searchText = '',
  });

  EnvironmentState copyWith({
    List<EnvironmentEntity> data,
    bool search,
    String searchText,
  }) {
    return EnvironmentState(
      data: data ?? this.data,
      search: search ?? this.search,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List get props => [data, search, searchText];
}
