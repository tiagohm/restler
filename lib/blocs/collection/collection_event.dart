import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';

abstract class CollectionEvent {}

class CollectionFetched extends CollectionEvent {
  final bool forced;

  CollectionFetched({
    this.forced = false,
  });
}

class SearchTextChanged extends CollectionEvent {
  final String text;

  SearchTextChanged(this.text);
}

class SearchToggled extends CollectionEvent {}

class FolderCreated extends CollectionEvent {
  final String name;

  FolderCreated(this.name);
}

class FolderEdited extends CollectionEvent {
  final FolderEntity folder;

  FolderEdited(this.folder);
}

class FolderMoved extends CollectionEvent {
  final FolderEntity folder;
  final WorkspaceEntity workspace;
  final FolderEntity parent;

  FolderMoved(this.folder, this.workspace, this.parent);
}

class FolderFavorited extends FolderEdited {
  FolderFavorited(FolderEntity folder)
      : super(folder.copyWith(favorite: !folder.favorite));
}

class FolderDuplicated extends CollectionEvent {
  final FolderEntity folder;

  FolderDuplicated(this.folder);
}

class FolderDeleted extends CollectionEvent {
  final FolderEntity folder;

  FolderDeleted(this.folder);
}

class CallEdited extends CollectionEvent {
  final CallEntity call;

  CallEdited(this.call);
}

class CallMoved extends CollectionEvent {
  final CallEntity call;
  final WorkspaceEntity workspace;
  final FolderEntity folder;

  CallMoved(this.call, this.workspace, this.folder);
}

class CallCopied extends CollectionEvent {
  final CallEntity call;
  final String name;
  final WorkspaceEntity workspace;
  final FolderEntity folder;

  CallCopied(this.call, this.name, this.workspace, this.folder);
}

class CallFavorited extends CallEdited {
  CallFavorited(CallEntity folder)
      : super(folder.copyWith(favorite: !folder.favorite));
}

class CallDuplicated extends CollectionEvent {
  final CallEntity call;

  CallDuplicated(this.call);
}

class CallDeleted extends CollectionEvent {
  final CallEntity call;

  CallDeleted(this.call);
}

class Forwarded extends CollectionEvent {
  final FolderEntity folder;

  Forwarded(this.folder);
}

class Backwarded extends CollectionEvent {}

enum ImportType { insomniaJson, insomniaYaml, restler, postman }

class ImportData {
  final String filepathOrUrl;
  final ImportType type;
  final String password;

  ImportData(this.filepathOrUrl, this.type, this.password);
}

class CollectionImported extends CollectionEvent {
  final ImportData data;
  final FolderEntity parent;

  CollectionImported(
    this.data, [
    this.parent = FolderEntity.root,
  ]);
}

enum ExportType { insomniaJson, restler, postman }

class ExportData {
  final ExportType type;
  final String password;
  final String name;

  ExportData(
    this.type,
    this.password,
    this.name,
  );
}

class CollectionExported extends CollectionEvent {
  final ExportData data;
  final String path;

  CollectionExported(this.data, this.path);
}
