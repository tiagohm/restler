import 'package:restler/blocs/dropdown/bloc.dart';
import 'package:restler/blocs/dropdown/dropdown_state.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/repositories/workspace_repository.dart';
import 'package:restler/inject.dart';

class WorkspaceDropdownBloc extends DropdownBloc<WorkspaceEntity> {
  final WorkspaceEntity selected;
  final _workspaceRepository = kiwi<WorkspaceRepository>();

  WorkspaceDropdownBloc(this.selected)
      : super(
          DropdownState(
            data: [
              WorkspaceEntity.empty,
              if (selected != null && selected != WorkspaceEntity.empty)
                selected,
            ],
            selected: selected ?? WorkspaceEntity.empty,
          ),
        );

  @override
  Stream<DropdownState<WorkspaceEntity>> mapPopulatedToState(
    Populated event,
  ) async* {
    // Workspace selecionado.
    final workspace = selected ?? await _workspaceRepository.active();
    // Workspaces.
    final workspaces = await _workspaceRepository.all();

    yield DropdownState(
      data: [WorkspaceEntity.empty, ...workspaces],
      selected: workspace,
    );
  }
}
