import 'package:equatable/equatable.dart';

enum SortType { date, method, url, status, duration, size }

class Sort extends Equatable {
  final SortType type;
  final bool ascending;

  const Sort({
    this.type = SortType.date,
    this.ascending = false,
  });

  static const empty = Sort();

  @override
  List get props => [type, ascending];
}
