import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/certificate_entity.dart';

class CertificateState extends Equatable {
  final List<CertificateEntity> data;
  final bool search;
  final String searchText;

  const CertificateState({
    this.data = const [],
    this.search = false,
    this.searchText = '',
  });

  CertificateState copyWith({
    List<CertificateEntity> data,
    bool search,
    String searchText,
  }) {
    return CertificateState(
      data: data ?? this.data,
      search: search ?? this.search,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List get props => [data, search, searchText];
}
