import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:url_launcher/url_launcher.dart';

class DescriptionDialog extends StatefulWidget {
  final String description;

  const DescriptionDialog({
    Key key,
    this.description,
  }) : super(key: key);

  static Future<DialogResult<String>> show(
    BuildContext context,
    String description,
  ) async {
    return showDialog<DialogResult<String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DescriptionDialog(description: description),
    );
  }

  @override
  _DescriptionDialogState createState() => _DescriptionDialogState();
}

class _DescriptionDialogState extends State<DescriptionDialog>
    with StateMixin<DescriptionDialog> {
  final _edit = ValueNotifier<bool>(false);
  TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController(text: widget.description);
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
      title: i18n.description,
      // Edit or Preview.
      trailing: ValueListenableBuilder(
        valueListenable: _edit,
        builder: (context, value, child) {
          return IconButton(
            onPressed: () {
              _edit.value = !value;
            },
            icon: value
                ? const Icon(Icons.remove_red_eye)
                : const Icon(Icons.edit),
            tooltip: value ? i18n.preview : i18n.edit,
          );
        },
      ),
      bodyBuilder: (context) {
        return ValueListenableBuilder(
          valueListenable: _edit,
          builder: (context, value, child) {
            return value
                ? TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    autocorrect: false,
                    maxLines: null,
                    minLines: 13,
                    buildCounter: charCounter,
                    decoration: InputDecoration(
                      hintText: i18n.enterTextHere,
                    ),
                    style: defaultInputTextStyle,
                  )
                : SizedBox(
                    width: 0,
                    height: MediaQuery.of(context).size.height / 3.94,
                    child: Markdown(
                      data: _textController.value.text,
                      shrinkWrap: true,
                      onTapLink: (text, href, title) => launch(href),
                    ),
                  );
          },
        );
      },
    );
  }

  String _onSave() {
    return _textController.value.text;
  }
}
