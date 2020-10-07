import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:restler/blocs/collection/bloc.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

class ImportDialog extends StatefulWidget {
  const ImportDialog({
    Key key,
  }) : super(key: key);

  static Future<DialogResult<ImportData>> show(
    BuildContext context,
  ) async {
    return showDialog<DialogResult<ImportData>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ImportDialog(),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _ImportDialogState();
  }
}

class _ImportDialogState extends State<ImportDialog>
    with StateMixin<ImportDialog> {
  final _importType = ValueNotifier(ImportType.insomniaJson);
  final _filepathOrUrlController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _importType.dispose();
    _filepathOrUrlController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<ImportData>(
      doneText: i18n.import,
      onDone: _onImport,
      title: i18n.import,
      bodyBuilder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Import type.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Label.
                    Text('${i18n.format}: '),
                    // Dropdown.
                    ValueListenableBuilder(
                      valueListenable: _importType,
                      builder: (context, type, child) {
                        return DropdownButton<ImportType>(
                          value: type,
                          items: [
                            for (final item in ImportType.values)
                              DropdownMenuItem(
                                value: item,
                                child: Text(_obtainImportTypeName(item)),
                              ),
                          ],
                          onChanged: (type) {
                            _importType.value = type;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Body.
              ValueListenableBuilder<ImportType>(
                valueListenable: _importType,
                builder: (context, type, child) {
                  switch (type) {
                    case ImportType.insomniaJson:
                    case ImportType.insomniaYaml:
                      return _InsomniaBody(
                        filepathOrUrl: _filepathOrUrlController,
                      );
                    case ImportType.restler:
                      return _RestlerBody(
                        filepathOrUrl: _filepathOrUrlController,
                        password: _passwordController,
                      );
                    case ImportType.postman:
                      return _PostmanBody(
                        filepathOrUrl: _filepathOrUrlController,
                      );
                    default:
                      return null;
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _obtainImportTypeName(ImportType type) {
    switch (type) {
      case ImportType.insomniaJson:
        return 'Insomnia (JSON)';
      case ImportType.insomniaYaml:
        return 'Insomnia (YAML)';
      case ImportType.restler:
        return 'Restler';
      case ImportType.postman:
        return 'Postman';
      default:
        return null;
    }
  }

  Future<ImportData> _onImport() async {
    final path = _filepathOrUrlController.text;
    final password = _passwordController.text;

    if (path.isEmpty) {
      return null;
    } else if (_importType.value == ImportType.restler &&
        password.isNotEmpty &&
        (password.length < 8 || password.length > 32)) {
      return null;
    } else {
      return ImportData(
        path,
        _importType.value,
        password,
      );
    }
  }
}

// Insomnia.

class _InsomniaBody extends StatefulWidget {
  final TextEditingController filepathOrUrl;

  const _InsomniaBody({
    Key key,
    @required this.filepathOrUrl,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InsomniaBodyState();
  }
}

class _InsomniaBodyState extends State<_InsomniaBody>
    with StateMixin<_InsomniaBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Filepath or URL.
        Flexible(
          child: PowerfulTextField(
            controller: widget.filepathOrUrl,
            hintText: i18n.filepathOrUrl,
          ),
        ),
        // Choose.
        RaisedButton.icon(
          icon: const Icon(Mdi.file),
          label: Text(i18n.chooseFile),
          onPressed: _onChooseFile,
          color: Colors.orange,
        ),
      ],
    );
  }

  void _onChooseFile() async {
    final res = await FilePicker.platform.pickFiles();

    if (res != null && res.files.isNotEmpty) {
      widget.filepathOrUrl.text = res.paths[0];
    }
  }
}

// Postman.

class _PostmanBody extends StatefulWidget {
  final TextEditingController filepathOrUrl;

  const _PostmanBody({
    Key key,
    @required this.filepathOrUrl,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PostmanBodyState();
  }
}

class _PostmanBodyState extends State<_PostmanBody>
    with StateMixin<_PostmanBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Filepath or URL.
        Flexible(
          child: PowerfulTextField(
            controller: widget.filepathOrUrl,
            hintText: i18n.filepathOrUrl,
          ),
        ),
        // Choose.
        RaisedButton.icon(
          icon: const Icon(Mdi.file),
          label: Text(i18n.chooseFile),
          onPressed: _onChooseFile,
          color: Colors.orange,
        ),
      ],
    );
  }

  void _onChooseFile() async {
    final res = await FilePicker.platform.pickFiles();

    if (res != null && res.files.isNotEmpty) {
      widget.filepathOrUrl.text = res.paths[0];
    }
  }
}

// Restler.

class _RestlerBody extends StatefulWidget {
  final TextEditingController filepathOrUrl;
  final TextEditingController password;

  const _RestlerBody({
    Key key,
    this.filepathOrUrl,
    this.password,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RestlerBodyState();
  }
}

class _RestlerBodyState extends State<_RestlerBody>
    with StateMixin<_RestlerBody> {
  var _invalidPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Filepath or URL.
        Flexible(
          child: PowerfulTextField(
            controller: widget.filepathOrUrl,
            hintText: i18n.filepathOrUrl,
          ),
        ),
        // Choose.
        RaisedButton.icon(
          icon: const Icon(Mdi.file),
          label: Text(i18n.chooseFile),
          onPressed: _onChooseFile,
          color: Colors.orange,
        ),
        // Password.
        Flexible(
          child: PowerfulTextField(
            controller: widget.password,
            decoration: InputDecoration(
              labelText: i18n.password,
              hintText: i18n.optional,
              errorText: _invalidPassword ? i18n.invalidPassword : null,
            ),
            onChanged: (text) {
              setState(() {
                _invalidPassword =
                    text.isNotEmpty && (text.length < 8 || text.length > 32);
              });
            },
            maxLength: 32,
            isPassword: true,
          ),
        ),
      ],
    );
  }

  void _onChooseFile() async {
    final res = await FilePicker.platform.pickFiles();

    if (res != null && res.files.isNotEmpty) {
      widget.filepathOrUrl.text = res.paths[0];
    }
  }
}
