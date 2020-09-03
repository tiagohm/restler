import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/proxy_entity.dart';

class ProxyState extends Equatable {
  final List<ProxyEntity> data;
  final bool search;
  final String searchText;

  const ProxyState({
    this.data = const [],
    this.search = false,
    this.searchText = '',
  });

  ProxyState copyWith({
    List<ProxyEntity> data,
    bool search,
    String searchText,
  }) {
    return ProxyState(
      data: data ?? this.data,
      search: search ?? this.search,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List get props => [data, search, searchText];
}
