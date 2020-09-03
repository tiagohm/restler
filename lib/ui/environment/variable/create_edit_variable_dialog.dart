import 'package:flutter/material.dart';
import 'package:restler/data/entities/variable_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';
import 'package:restler/ui/widgets/variable_name_formatter.dart';

class CreateEditVariableDialog extends StatefulWidget {
  final VariableEntity variable;

  const CreateEditVariableDialog(this.variable);

  static Future<DialogResult<List>> show(
    BuildContext context,
    VariableEntity variable,
  ) async {
    return showDialog<DialogResult<List>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateEditVariableDialog(variable),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return CreateOrEditVariableState();
  }
}

class CreateOrEditVariableState extends State<CreateEditVariableDialog>
    with StateMixin<CreateEditVariableDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameTextController;
  TextEditingController _valueTextController;
  bool _isSecret;

  @override
  void initState() {
    _nameTextController =
        TextEditingController(text: widget.variable?.name ?? '');
    _valueTextController =
        TextEditingController(text: widget.variable?.value ?? '');
    _isSecret = widget.variable?.secret ?? false;

    super.initState();
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _valueTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<List>(
      doneText: i18n.save,
      title: widget.variable == null ? i18n.newVariable : i18n.editVariable,
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
                  validator: (text) => text.isEmpty ? i18n.required : null,
                  decoration: InputDecoration(labelText: i18n.name),
                  inputFormatters: const [VariableNameFormatter()],
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                // Value.
                PowerfulTextField(
                  controller: _valueTextController,
                  decoration: InputDecoration(labelText: i18n.value),
                  style: defaultInputTextStyle,
                  obscureText: _isSecret,
                  suggestionsCallback: variableSuggestions,
                  showDefaultItems: false,
                ),
                // Secret.
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _isSecret,
                      onChanged: widget.variable != null &&
                              widget.variable.secret &&
                              widget.variable.value != null &&
                              widget.variable.value.isNotEmpty
                          ? null
                          : _onSecret,
                    ),
                    Text(i18n.secret),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSecret(bool enabled) {
    setState(() {
      _isSecret = enabled;
    });
  }

  Future<List> _onSave() async {
    if (_formKey.currentState.validate()) {
      return [
        _nameTextController.text,
        _valueTextController.text,
        _isSecret,
      ];
    } else {
      return null;
    }
  }
}
