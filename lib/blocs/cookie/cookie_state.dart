import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/cookie_entity.dart';

class CookieState extends Equatable {
  final List<CookieEntity> data;
  final bool search;
  final String searchText;

  const CookieState({
    this.data = const [],
    this.search = false,
    this.searchText = '',
  });

  CookieState copyWith({
    List<CookieEntity> data,
    bool search,
    String searchText,
  }) {
    return CookieState(
      data: data ?? this.data,
      search: search ?? this.search,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List get props => [data, search, searchText];
}
