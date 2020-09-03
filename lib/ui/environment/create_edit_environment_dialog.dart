import 'package:flutter/material.dart';
import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class CreateEditEnvironmentDialog extends StatefulWidget {
  final EnvironmentEntity environment;

  const CreateEditEnvironmentDialog(this.environment);

  static Future<DialogResult<String>> show(
    BuildContext context,
    EnvironmentEntity environment,
  ) async {
    return showDialog<DialogResult<String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateEditEnvironmentDialog(environment),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return CreateOrEditEnvironmentState();
  }
}

class CreateOrEditEnvironmentState extends State<CreateEditEnvironmentDialog>
    with StateMixin<CreateEditEnvironmentDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameTextController;

  @override
  void initState() {
    _nameTextController =
        TextEditingController(text: widget.environment?.name ?? '');
    super.initState();
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<String>(
      doneText: i18n.save,
      title: widget.environment == null
          ? i18n.newEnvironment
          : i18n.editEnvironment,
      onDone: _onSave,
      bodyBuilder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 4),
          child: Form(
            key: _formKey,
            child: ListBody(
              children: [
                // Name.
                TextFormField(
                  controller: _nameTextController,
                  validator: textIsRequired,
                  decoration: InputDecoration(labelText: i18n.name),
                  style: defaultInputTextStyle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _onSave() async {
    if (_formKey.currentState.validate()) {
      return _nameTextController.text.trim();
    } else {
      return null;
    }
  }
}
