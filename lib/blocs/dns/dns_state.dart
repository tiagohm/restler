import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/dns_entity.dart';

class DnsState extends Equatable {
  final List<DnsEntity> data;
  final bool search;
  final String searchText;

  const DnsState({
    this.data = const [],
    this.search = false,
    this.searchText = '',
  });

  DnsState copyWith({
    List<DnsEntity> data,
    bool search,
    String searchText,
  }) {
    return DnsState(
      data: data ?? this.data,
      search: search ?? this.search,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List get props => [data, search, searchText];
}
