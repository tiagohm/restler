import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/dropdown/bloc.dart';
import 'package:restler/blocs/dropdown/workspace_dropdown_bloc.dart';
import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class CopyEnvironmentDialog extends StatefulWidget {
  final EnvironmentEntity environment;

  const CopyEnvironmentDialog({
    Key key,
    @required this.environment,
  }) : super(key: key);

  static Future<DialogResult<List>> show(
    BuildContext context,
    EnvironmentEntity environment,
  ) async {
    return showDialog<DialogResult<List>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CopyEnvironmentDialog(environment: environment),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _CopyEnvironmentDialogState();
  }
}

class _CopyEnvironmentDialogState extends State<CopyEnvironmentDialog>
    with StateMixin<CopyEnvironmentDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameTextController;
  WorkspaceDropdownBloc _workspaceDropdownBloc;

  @override
  void initState() {
    _nameTextController = TextEditingController(text: widget.environment.name);
    _workspaceDropdownBloc =
        WorkspaceDropdownBloc(widget.environment.workspace);
    _workspaceDropdownBloc.add(Populated());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<List>(
      title: i18n.copyEnvironment,
      onCancel: () => null,
      onDone: () {
        if (_formKey.currentState.validate()) {
          return [
            _nameTextController.text,
            _workspaceDropdownBloc.state.selected,
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
                // Name.
                TextFormField(
                  decoration: InputDecoration(
                    icon: const Icon(Icons.edit),
                    labelText: i18n.name,
                  ),
                  controller: _nameTextController,
                  maxLength: 32,
                  validator: textIsRequired,
                  style: defaultInputTextStyle,
                ),
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
