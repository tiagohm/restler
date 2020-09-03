import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';

abstract class WorkspaceEvent {}

class WorkspaceFetched extends WorkspaceEvent {}

class WorkspaceSelected extends WorkspaceEvent {
  final WorkspaceEntity workspace;

  WorkspaceSelected(this.workspace);
}

class WorkspaceCreated extends WorkspaceEvent {
  final String name;

  WorkspaceCreated(this.name);
}

class WorkspaceEdited extends WorkspaceEvent {
  final String name;

  WorkspaceEdited(this.name);
}

class WorkspaceDeleted extends WorkspaceEvent {}

class WorkspaceCleared extends WorkspaceEvent {}

class EnvironmentSelected extends WorkspaceEvent {
  final EnvironmentEntity environment;

  EnvironmentSelected(this.environment);
}

class WorkspaceDuplicated extends WorkspaceEvent {}
