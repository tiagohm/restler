import 'package:equatable/equatable.dart';
import 'package:sqler/sqler.dart';

final workspaceTable = table('workspace');
final workspaceUid = col('ws_uid');
final workspaceName = col('ws_name');
final workspaceActive = col('ws_active');
final workspaceHidden = col('ws_hidden');

class WorkspaceEntity extends Equatable {
  final String uid;
  final String name;
  final bool active;
  final bool hidden;

  const WorkspaceEntity({
    this.uid,
    this.name,
    this.active = false,
    this.hidden = false,
  }) : assert(hidden != null);

  static const empty = WorkspaceEntity(name: 'Restler');

  factory WorkspaceEntity.fromDatabase(Map<String, dynamic> db) {
    if (db == null || db['ws_uid'] == null) {
      return WorkspaceEntity.empty;
    }

    return WorkspaceEntity(
      uid: db['ws_uid'],
      name: db['ws_name'] ?? '',
      active: db['ws_active'] == 1,
      hidden: db['ws_hidden'] == 1,
    );
  }

  factory WorkspaceEntity.fromJson(Map<String, dynamic> json) {
    if (json == null || json['uid'] == null) {
      return empty;
    } else {
      return WorkspaceEntity(
        uid: json['uid'],
        name: json['name'],
        active: json['active'] ?? false,
        hidden: json['hidden'] ?? false,
      );
    }
  }

  Map<String, dynamic> toDatabase() {
    return {
      'ws_uid': uid,
      'ws_name': name,
      'ws_active': active ? 1 : 0,
      'ws_hidden': hidden ? 1 : 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'active': active,
      'hidden': hidden,
    };
  }

  WorkspaceEntity copyWith({
    String uid,
    String name,
    bool active,
    bool hidden,
  }) {
    return WorkspaceEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      active: active ?? this.active,
      hidden: hidden ?? this.hidden,
    );
  }

  @override
  List<Object> get props => [uid, name, active, hidden];

  @override
  String toString() {
    return 'Workspace { uid: $uid, name: $name, active: $active, hidden: $hidden }';
  }
}
