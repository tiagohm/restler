import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/response_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';

class TabEntity extends Equatable {
  final String uid;
  final String name;
  final RequestEntity request;
  final ResponseEntity response;
  final String call;
  final bool favorited;
  final int openedAt;
  final bool saved;
  final WorkspaceEntity workspace;

  const TabEntity({
    this.uid,
    this.name,
    this.call,
    this.request = RequestEntity.empty,
    this.response = ResponseEntity.empty,
    this.favorited = false,
    this.openedAt = 0,
    this.saved = false,
    this.workspace = WorkspaceEntity.empty,
  });

  TabEntity.fromDatabase(Map<String, dynamic> db)
      : uid = db['tab_uid'],
        name = db['tab_name'],
        call = db['tab_call'],
        request = RequestEntity.fromDatabase(db),
        response = ResponseEntity.empty,
        favorited = db['tab_favorited'] == 1,
        openedAt = db['tab_opened_at'],
        saved = db['tab_saved'] == 1,
        workspace = WorkspaceEntity.fromDatabase(db);

  TabEntity copyWith({
    String uid,
    String name,
    String call,
    RequestEntity request,
    ResponseEntity response,
    bool favorited,
    int openedAt,
    bool saved,
    WorkspaceEntity workspace,
  }) {
    return TabEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      request: request ?? this.request,
      response: response ?? this.response,
      call: call ?? this.call,
      favorited: favorited ?? this.favorited,
      openedAt: openedAt ?? this.openedAt,
      saved: saved ?? this.saved,
      workspace: workspace ?? this.workspace,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'tab_uid': uid,
      'tab_name': name,
      'tab_call': call,
      'tab_request': request.uid,
      'tab_saved': saved ? 1 : 0,
      'tab_opened_at': openedAt,
      'tab_favorited': favorited ? 1 : 0,
      'tab_hidden': 0,
      'tab_position': 0,
      'tab_workspace': workspace?.uid,
    };
  }

  @override
  List get props => [
        uid,
        name,
        request,
        call,
        favorited,
        openedAt,
        saved,
        workspace,
      ];

  @override
  String toString() {
    return 'Tab { uid: $uid, name: $name, request: $request,'
        ' call: $call, favorited: $favorited, openedAt: $openedAt, saved: $saved,'
        ' workspace: $workspace }';
  }
}
