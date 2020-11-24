import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restler/helper.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class WebSocketBodyPage extends StatefulWidget {
  final String text;
  final ValueChanged<String> onTextChanged;

  const WebSocketBodyPage({
    Key key,
    @required this.text,
    this.onTextChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WebSocketBodyState();
  }
}

class _WebSocketBodyState extends State<WebSocketBodyPage>
    with StateMixin<WebSocketBodyPage> {
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
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: TextField(
              expands: true,
              controller: _textController,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              autocorrect: false,
              maxLines: null,
              buildCounter: charCounter,
              decoration: InputDecoration(
                // fillColor: Theme.of(context).scaffoldBackgroundColor,
                // filled: true,
                hintText: i18n.enterTextHere,
                // border: OutlineInputBorder(),
              ),
              style: defaultInputTextStyle,
              onChanged: widget.onTextChanged,
            ),
          ),
          // Botões.
          Positioned(
            right: 0,
            top: 0,
            child: Material(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Paste.
                  IconButton(
                    icon: const Icon(Icons.content_paste),
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');

                      if (data?.text != null) {
                        final text = insertTextAtCursorPosition(
                            _textController, data.text);
                        widget.onTextChanged(text);
                      }
                    },
                  ),
                  // Clear.
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _textController.clear();
                      widget.onTextChanged('');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
