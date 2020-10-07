import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:restio/restio.dart';
import 'package:restler/i18n.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/action_button.dart';
import 'package:restler/ui/widgets/label.dart';

class RequestBodyFilePage extends StatelessWidget {
  final String path;
  final ValueChanged<String> onFileChoosed;
  final File file;

  RequestBodyFilePage({
    Key key,
    @required this.path,
    this.onFileChoosed,
  })  : file = path == null ? null : File(path),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

    // File.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            // Path.
            Container(
              height: 64,
              child: Center(
                child: Text(
                  path == null || path.isEmpty ? i18n.noFileSelected : path,
                  style: defaultInputTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // File info.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (path != null && path.isNotEmpty)
                    if (file.existsSync())
                      Label(
                        text: '${file.lengthSync()} B',
                        color: Colors.green,
                      )
                    else
                      Label(
                        text: i18n.error,
                        color: Colors.red,
                      ),
                  Container(width: 4),
                  if (path != null && path.isNotEmpty)
                    Label(
                      text: MediaType.fromFile(path).mimeType,
                      color: Colors.blue,
                    ),
                ],
              ),
            ),
            Container(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // Choose...
                ActionButton(
                  text: i18n.choose,
                  onPressed: _onChoose,
                ),
                // Remove.
                ActionButton(
                  text: i18n.remove,
                  onPressed: () {
                    onFileChoosed?.call(null);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onChoose() async {
    try {
      final res = await FilePicker.platform.pickFiles();

      if (res != null && res.files.isNotEmpty) {
        onFileChoosed?.call(res.paths[0]);
      }
    } on Exception catch (e) {
      print('Error while picking the file: $e');
    }
  }
}
