import 'package:restler/blocs/history/sort.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/history_entity.dart';

abstract class HistoryEvent {}

class HistoryFetched extends HistoryEvent {}

class SearchTextChanged extends HistoryEvent {
  final String text;

  SearchTextChanged(this.text);
}

class SearchToggled extends HistoryEvent {}

class HistoryDeleted extends HistoryEvent {
  final HistoryEntity history;

  HistoryDeleted(this.history);
}

class HistoryCleared extends HistoryEvent {}

class HistorySorted extends HistoryEvent {
  final Sort sort;

  HistorySorted(this.sort);
}

class HistorySaved extends HistoryEvent {
  final HistoryEntity history;
  final String name;
  final FolderEntity folder;

  HistorySaved(this.history, this.name, this.folder);
}
