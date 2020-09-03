import 'package:flutter/material.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/uppercase_formatter.dart';

class InputTextDialog extends StatefulWidget {
  final String text;
  final String title;
  final String label;
  final bool uppercase;
  final TextInputType keyboardType;
  final int maxLength;
  final IconData icon;

  const InputTextDialog({
    Key key,
    @required this.text,
    @required this.title,
    @required this.label,
    this.uppercase = false,
    this.keyboardType,
    this.maxLength = 32,
    this.icon,
  }) : super(key: key);

  static Future<DialogResult<String>> show(
    BuildContext context,
    String text,
    String label,
    String title, {
    bool uppercase = false,
    TextInputType keyboardType,
    int maxLength = 32,
    IconData icon,
  }) async {
    return showDialog<DialogResult<String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => InputTextDialog(
        text: text,
        label: label,
        title: title,
        uppercase: uppercase,
        keyboardType: keyboardType,
        maxLength: maxLength,
        icon: icon,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _InputTextDialogState();
  }
}

class _InputTextDialogState extends State<InputTextDialog>
    with StateMixin<InputTextDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController(text: widget.text);
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<String>(
      title: widget.title,
      onCancel: () => null,
      onDone: () {
        if (_formKey.currentState.validate()) {
          return _textController.text;
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
                // Text.
                TextFormField(
                  controller: _textController,
                  validator: (text) => text.isEmpty ? i18n.required : null,
                  inputFormatters: [
                    if (widget.uppercase) const UppercaseFormatter(),
                  ],
                  maxLength: widget.maxLength,
                  decoration: InputDecoration(
                    icon: Icon(widget.icon ?? Icons.edit),
                    labelText: widget.label,
                  ),
                  keyboardType: widget.keyboardType ?? TextInputType.text,
                  autocorrect: false,
                  style: defaultInputTextStyle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
