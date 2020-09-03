import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/response_entity.dart';
import 'package:restler/data/entities/tab_entity.dart';

abstract class TabEvent {}

class TabFetched extends TabEvent {}

class TabOpened extends TabEvent {
  final TabEntity tab;
  final bool createNew;

  TabOpened(
    this.tab, {
    this.createNew = false,
  });
}

class TabClosed extends TabEvent {
  final TabEntity tab;

  TabClosed(this.tab);
}

class TabSaved extends TabEvent {}

class TabSavedAs extends TabEvent {
  final String name;
  final FolderEntity folder;

  TabSavedAs(this.name, this.folder);
}

class TabEdited extends TabEvent {
  final RequestEntity request;
  final ResponseEntity response;

  TabEdited({
    this.request,
    this.response,
  });
}

class TabReseted extends TabEvent {}

class TabDuplicated extends TabEvent {}

class TabReopened extends TabEvent {}

class TabRenamed extends TabEvent {
  final String name;

  TabRenamed(this.name);
}

class TabCallDeleted extends TabEvent {}
