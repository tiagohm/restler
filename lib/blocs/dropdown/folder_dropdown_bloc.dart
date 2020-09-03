import 'package:restler/blocs/dropdown/bloc.dart';
import 'package:restler/blocs/dropdown/dropdown_state.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/repositories/collection_repository.dart';
import 'package:restler/data/repositories/workspace_repository.dart';
import 'package:restler/inject.dart';

class FolderDropdownBloc extends DropdownBloc<FolderEntity> {
  final FolderEntity selected;
  final _workspaceRepository = kiwi<WorkspaceRepository>();
  final _collectionRepository = kiwi<CollectionRepository>();

  FolderDropdownBloc(this.selected)
      : super(DropdownState(
          data: [
            FolderEntity.root,
            if (selected != null && selected.parent != FolderEntity.root)
              selected.parent,
          ],
          selected: selected.parent ?? FolderEntity.root,
        ));

  List<FolderEntity> filter(List<FolderEntity> data) {
    return data;
  }

  @override
  Stream<DropdownState<FolderEntity>> mapPopulatedToState(
    Populated event,
  ) async* {
    // Workspace selecionado.
    final workspace =
        event.data['workspace'] ?? await _workspaceRepository.active();
    // Obtém as pastas do workspace selecionado.
    final data = await _collectionRepository.allFolders(workspace);

    yield DropdownState(
      data: [
        FolderEntity.root,
        ...filter(data),
      ],
      selected: selected.parent ?? FolderEntity.root,
    );
  }
}
