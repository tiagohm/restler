import 'package:flutter/material.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class MultilineTextDialog extends StatefulWidget {
  final String title;
  final String text;
  final AutocompleteItemSuggestionCallback suggestionsCallback;

  const MultilineTextDialog({
    Key key,
    @required this.title,
    this.text = '',
    this.suggestionsCallback,
  }) : super(key: key);

  static Future<DialogResult<String>> show(
    BuildContext context,
    String title,
    String text, {
    AutocompleteItemSuggestionCallback suggestionsCallback,
  }) async {
    return showDialog<DialogResult<String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MultilineTextDialog(
        title: title,
        text: text,
        suggestionsCallback: suggestionsCallback,
      ),
    );
  }

  @override
  _MultilineTextDialogState createState() => _MultilineTextDialogState();
}

class _MultilineTextDialogState extends State<MultilineTextDialog>
    with StateMixin<MultilineTextDialog> {
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
      doneText: i18n.save,
      onDone: _onSave,
      title: widget.title,
      bodyBuilder: (context) {
        return PowerfulTextField(
          controller: _textController,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          autocorrect: false,
          maxLines: null,
          minLines: 8,
          buildCounter: charCounter,
          decoration: InputDecoration(
            hintText: i18n.enterTextHere,
          ),
          style: defaultInputTextStyle,
          suggestionsCallback: widget.suggestionsCallback,
          autoFlipDirection: false,
        );
      },
    );
  }

  String _onSave() {
    return _textController.value.text;
  }
}
