import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:sqler/sqler.dart';

final variableTable = table('variable');
final variableUid = col('var_uid');
final variableName = col('var_name');
final variableValue = col('var_value');
final variableEnabled = col('var_enabled');
final variableWorkspace = col('var_workspace');
final variableEnvironment = col('var_environment');
final variableSecret = col('var_secret');

class VariableEntity extends Equatable {
  final String uid;
  final String name;
  final String value;
  final bool enabled;
  final EnvironmentEntity environment; // nulo é pq pertence ao ambiente Global.
  final WorkspaceEntity workspace;
  final bool secret;

  const VariableEntity({
    this.uid,
    this.name,
    this.value,
    this.enabled = true,
    this.environment = EnvironmentEntity.none,
    this.workspace = WorkspaceEntity.empty,
    this.secret = false,
  });

  static const empty = VariableEntity();

  factory VariableEntity.fromDatabase(Map<String, dynamic> db) {
    if (db == null || db['var_uid'] == null) {
      return null;
    } else {
      return VariableEntity(
        uid: db['var_uid'],
        name: db['var_name'],
        value: db['var_value'],
        enabled: db['var_enabled'] == 1,
        environment: EnvironmentEntity.fromDatabase(db),
        workspace: WorkspaceEntity.fromDatabase(db),
        secret: db['var_secret'] == 1,
      );
    }
  }

  factory VariableEntity.fromJson(Map<String, dynamic> json) {
    if (json == null || json['uid'] == null) {
      return null;
    } else {
      return VariableEntity(
        uid: json['uid'],
        name: json['name'],
        value: json['value'],
        enabled: json['enabled'] == 1,
        environment: EnvironmentEntity.fromJson(json['environment']),
        workspace: WorkspaceEntity.fromJson(json['workspace']),
        secret: json['secret'] == 1,
      );
    }
  }

  Map<String, dynamic> toDatabase() {
    return {
      'var_uid': uid,
      'var_name': name,
      'var_value': value,
      'var_enabled': enabled ? 1 : 0,
      'var_environment': environment?.uid,
      'var_workspace': workspace?.uid,
      'var_secret': secret ? 1 : 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'value': value,
      'enabled': enabled,
      'environment': environment?.toJson(),
      'workspace': workspace?.toJson(),
      'secret': secret,
    };
  }

  VariableEntity copyWith({
    String uid,
    String name,
    String value,
    bool enabled,
    EnvironmentEntity environment,
    WorkspaceEntity workspace,
    bool secret,
  }) {
    return VariableEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      value: value ?? this.value,
      enabled: enabled ?? this.enabled,
      environment: environment ?? this.environment,
      workspace: workspace ?? this.workspace,
      secret: secret ?? this.secret,
    );
  }

  @override
  List<Object> get props => [
        uid,
        name,
        value,
        enabled,
        environment,
        workspace,
        secret,
      ];

  @override
  String toString() {
    return 'Variable { uid: $uid, name: $name, value: $value, enabled: $enabled,'
        ' environment: $environment, workspace: $workspace, secret: $secret }';
  }
}
