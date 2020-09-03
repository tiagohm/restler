import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';

class WorkspaceState extends Equatable {
  final List<WorkspaceEntity> workspaces;
  final WorkspaceEntity currentWorkspace;
  final List<EnvironmentEntity> environments;
  final EnvironmentEntity currentEnvironment;

  const WorkspaceState({
    this.workspaces = const [WorkspaceEntity.empty],
    this.currentWorkspace = WorkspaceEntity.empty,
    this.environments = const [], // Global não é selecionável.
    this.currentEnvironment, // Nenhum ambiente selecionado.
  });

  WorkspaceState copyWith({
    List<WorkspaceEntity> workspaces,
    WorkspaceEntity currentWorkspace,
    List<EnvironmentEntity> environments,
    EnvironmentEntity currentEnvironment,
  }) {
    return WorkspaceState(
      workspaces: workspaces ?? this.workspaces,
      currentWorkspace: currentWorkspace ?? this.currentWorkspace,
      environments: environments ?? this.environments,
      currentEnvironment: currentEnvironment ?? this.currentEnvironment,
    );
  }

  @override
  List<Object> get props => [
        workspaces,
        currentWorkspace,
        environments,
        currentEnvironment,
      ];
}
