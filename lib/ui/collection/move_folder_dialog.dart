import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/dropdown/bloc.dart';
import 'package:restler/blocs/dropdown/folder_dropdown_bloc.dart';
import 'package:restler/blocs/dropdown/workspace_dropdown_bloc.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/folder_item.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class MoveFolderDialog extends StatefulWidget {
  final FolderEntity folder;

  const MoveFolderDialog({
    Key key,
    @required this.folder,
  }) : super(key: key);

  static Future<DialogResult<List>> show(
    BuildContext context,
    FolderEntity folder,
  ) async {
    return showDialog<DialogResult<List>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MoveFolderDialog(folder: folder),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _MoveFolderDialogState();
  }
}

class _MoveFolderDialogState extends State<MoveFolderDialog>
    with StateMixin<MoveFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  WorkspaceDropdownBloc _workspaceDropdownBloc;
  _FolderDropdownBloc _folderDropdownBloc;

  @override
  void initState() {
    _workspaceDropdownBloc = WorkspaceDropdownBloc(widget.folder.workspace);
    _workspaceDropdownBloc.add(Populated());
    _folderDropdownBloc = _FolderDropdownBloc(widget.folder);
    _folderDropdownBloc.add(Populated());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<List>(
      title: i18n.moveFolder,
      onCancel: () => null,
      onDone: () {
        if (_formKey.currentState.validate()) {
          return [
            _workspaceDropdownBloc.state.selected,
            _folderDropdownBloc.state.selected,
          ];
        } else {
          return null;
        }
      },
      bodyBuilder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 4),
          child: Form(
            key: _formKey,
            child: ListBody(
              children: [
                // Workspace.
                BlocBuilder<DropdownBloc<WorkspaceEntity>,
                    DropdownState<WorkspaceEntity>>(
                  key: const Key('dropdown-workspace'),
                  cubit: _workspaceDropdownBloc,
                  builder: (context, state) {
                    return DropdownButtonFormField<WorkspaceEntity>(
                      key: Key(state.selected?.uid),
                      decoration: InputDecoration(
                        icon: const Icon(Mdi.workspace),
                        labelText: i18n.workspace,
                      ),
                      items: mapWorkspaceEntityToDropdownItem(state.data),
                      value: state.selected,
                      onChanged: (workspace) {
                        _workspaceDropdownBloc.add(ItemSelected(workspace));
                        _folderDropdownBloc
                            .add(Populated({'workspace': workspace}));
                      },
                      validator: itemIsRequired,
                      style: defaultInputTextStyle,
                    );
                  },
                ),
                // Folder.
                BlocBuilder<DropdownBloc<FolderEntity>,
                    DropdownState<FolderEntity>>(
                  key: const Key('dropdown-folder'),
                  cubit: _folderDropdownBloc,
                  builder: (context, state) {
                    return DropdownButtonFormField<FolderEntity>(
                      key: Key(state.selected?.uid),
                      decoration: InputDecoration(
                        icon: const Icon(Icons.folder),
                        labelText: i18n.folder,
                      ),
                      items: _mapFolderEntityToDropdownItem(state.data),
                      value: state.selected,
                      onChanged: (folder) {
                        _folderDropdownBloc.add(ItemSelected(folder));
                      },
                      validator: itemIsRequired,
                      style: defaultInputTextStyle,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<DropdownMenuItem<FolderEntity>> _mapFolderEntityToDropdownItem(
    List<FolderEntity> data,
  ) {
    return [
      for (final item in data)
        DropdownMenuItem<FolderEntity>(
          value: item,
          child: FolderItem(item: item),
        ),
    ];
  }
}

class _FolderDropdownBloc extends FolderDropdownBloc {
  _FolderDropdownBloc(FolderEntity selected) : super(selected);

  @override
  List<FolderEntity> filter(List<FolderEntity> data) {
    data = [
      for (final item in data)
        if (selected.canMoveTo(item)) item,
    ];

    // As pastas-pai vem sempre primeiro em relação as pastas-filhas.
    return data
      ..sort((a, b) {
        if (a == b) return 0;
        if (a.isSubFolder(b)) return 1;
        if (b.isSubFolder(a)) return -1;
        return a.name.compareTo(b.name);
      });
  }
}
