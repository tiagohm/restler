import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/dropdown/bloc.dart';
import 'package:restler/blocs/dropdown/workspace_dropdown_bloc.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class MoveToWorkspaceDialog extends StatefulWidget {
  final WorkspaceEntity selected;
  final String title;

  const MoveToWorkspaceDialog({
    Key key,
    @required this.selected,
    @required this.title,
  }) : super(key: key);

  static Future<DialogResult<WorkspaceEntity>> show(
    BuildContext context,
    WorkspaceEntity selected,
    String title,
  ) async {
    return showDialog<DialogResult<WorkspaceEntity>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MoveToWorkspaceDialog(
        selected: selected,
        title: title,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _MoveToWorkspaceDialogState();
  }
}

class _MoveToWorkspaceDialogState extends State<MoveToWorkspaceDialog>
    with StateMixin<MoveToWorkspaceDialog> {
  final _formKey = GlobalKey<FormState>();
  WorkspaceDropdownBloc _workspaceDropdownBloc;

  @override
  void initState() {
    _workspaceDropdownBloc = WorkspaceDropdownBloc(widget.selected);
    _workspaceDropdownBloc.add(Populated());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<WorkspaceEntity>(
      title: widget.title,
      onCancel: () => null,
      onDone: () {
        if (_formKey.currentState.validate()) {
          return _workspaceDropdownBloc.state.selected;
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
}
