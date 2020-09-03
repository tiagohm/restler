import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:sqler/sqler.dart';

final environmentTable = table('environment');
final environmentUid = col('env_uid');
final environmentName = col('env_name');
final environmentEnabled = col('env_enabled');
final environmentActive = col('env_active');
final environmentWorkspace = col('env_workspace');

class EnvironmentEntity extends Equatable {
  final String uid;
  final String name;
  final bool enabled;
  final bool active;
  final WorkspaceEntity workspace;

  const EnvironmentEntity({
    this.uid,
    this.name,
    this.enabled = true,
    this.active = false,
    this.workspace = WorkspaceEntity.empty,
  });

  static const none = EnvironmentEntity(active: true, workspace: null);

  bool get isNoEnvironment => uid == null;

  bool get isGlobal => uid == null;

  factory EnvironmentEntity.fromDatabase(Map<String, dynamic> db) {
    if (db == null || db['env_uid'] == null) {
      return null;
    } else {
      return EnvironmentEntity(
        uid: db['env_uid'],
        name: db['env_name'],
        enabled: db['env_enabled'] == 1,
        active: db['env_active'] == 1,
        workspace: WorkspaceEntity.fromDatabase(db),
      );
    }
  }

  factory EnvironmentEntity.fromJson(Map<String, dynamic> json) {
    if (json == null || json['uid'] == null) {
      return null;
    } else {
      return EnvironmentEntity(
        uid: json['uid'],
        name: json['name'],
        enabled: json['enabled'] == 1,
        active: json['active'] == 1,
        workspace: WorkspaceEntity.fromJson(json['workspace']),
      );
    }
  }

  factory EnvironmentEntity.noEnvironment(WorkspaceEntity workspace) {
    return none.copyWith(workspace: workspace);
  }

  Map<String, dynamic> toDatabase() {
    return {
      'env_uid': uid,
      'env_name': name,
      'env_enabled': enabled ? 1 : 0,
      'env_active': active ? 1 : 0,
      'env_workspace': workspace?.uid,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'enabled': enabled,
      'active': active,
      'workspace': workspace?.toJson(),
    };
  }

  EnvironmentEntity copyWith({
    String uid,
    String name,
    bool enabled,
    bool active,
    WorkspaceEntity workspace,
  }) {
    return EnvironmentEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      active: active ?? this.active,
      workspace: workspace ?? this.workspace,
    );
  }

  @override
  List<Object> get props => [uid, name, enabled, active, workspace];

  @override
  String toString() {
    return 'Environment { uid: $uid, name: $name, enabled: $enabled, active: $active, workspace: $workspace }';
  }
}
