import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:sqler/sqler.dart';

final callTable = table('call');
final callUid = col('call_uid');
final callName = col('call_name');
final callRequest = col('call_request');
final callFolder = col('call_folder');
final callFavorite = col('call_favorite');
final callWorkspace = col('call_workspace');

class CallEntity extends Equatable {
  final String uid;
  final String name;
  final RequestEntity request;
  final FolderEntity folder;
  final bool favorite;
  final WorkspaceEntity workspace;

  const CallEntity({
    this.uid,
    this.name = '',
    this.folder = FolderEntity.root,
    this.request = RequestEntity.empty,
    this.favorite = false,
    this.workspace = WorkspaceEntity.empty,
  });

  static const empty = CallEntity();

  factory CallEntity.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return empty;
    } else {
      return CallEntity(
        uid: json['uid'],
        name: json['name'],
        folder: FolderEntity.fromJson(json['folder']),
        request: RequestEntity.fromJson(json['request']),
        favorite: json['favorite'],
        workspace: WorkspaceEntity.fromJson(json['workspace']),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'folder': folder?.toJson(),
      'request': request.toJson(),
      'favorite': favorite,
      'workspace': workspace?.toJson(),
    };
  }

  Map<String, dynamic> toDatabase() {
    return {
      'call_uid': uid,
      'call_name': name,
      'call_folder': folder?.uid,
      'call_request': request?.uid,
      'call_favorite': favorite ? 1 : 0,
      'call_workspace': workspace?.uid,
    };
  }

  // Use folder = false para setar como nulo.
  CallEntity copyWith({
    String uid,
    String name,
    RequestEntity request,
    folder,
    bool favorite,
    WorkspaceEntity workspace,
  }) {
    return CallEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      folder: folder == null
          ? this.folder
          : folder == false
              ? null
              : folder,
      request: request ?? this.request,
      favorite: favorite ?? this.favorite,
      workspace: workspace ?? this.workspace,
    );
  }

  @override
  List get props => [
        uid,
        name,
        request,
        folder,
        favorite,
        workspace,
      ];

  @override
  String toString() {
    return 'Call { uid: $uid, name: $name, folder: $folder,'
        ' request: $request, favorite: $favorite, workspace: $workspace }';
  }
}
