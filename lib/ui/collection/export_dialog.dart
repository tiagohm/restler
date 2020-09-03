import 'package:flutter/material.dart';
import 'package:restler/blocs/collection/bloc.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

class ExportDialog extends StatefulWidget {
  const ExportDialog({
    Key key,
  }) : super(key: key);

  static Future<DialogResult<ExportData>> show(
    BuildContext context,
  ) async {
    return showDialog<DialogResult<ExportData>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ExportDialog(),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _ExportDialogState();
  }
}

class _ExportDialogState extends State<ExportDialog>
    with StateMixin<ExportDialog> {
  final _exportType = ValueNotifier(ExportType.insomniaJson);
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _nameController.dispose();
    _exportType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<ExportData>(
      doneText: i18n.export,
      onDone: _onExport,
      title: i18n.export,
      bodyBuilder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Export type.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Label.
                    Text('${i18n.format}: '),
                    // Dropdown.
                    ValueListenableBuilder(
                      valueListenable: _exportType,
                      builder: (context, type, child) {
                        return DropdownButton<ExportType>(
                          value: type,
                          items: [
                            for (final item in ExportType.values)
                              DropdownMenuItem(
                                value: item,
                                child: Text(_obtainExportTypeName(item)),
                              ),
                          ],
                          onChanged: (type) {
                            _exportType.value = type;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Body.
              ValueListenableBuilder<ExportType>(
                valueListenable: _exportType,
                builder: (context, type, child) {
                  switch (type) {
                    case ExportType.insomniaJson:
                      return const _InsomniaBody();
                    case ExportType.restler:
                      return _RestlerBody(
                        password: _passwordController,
                      );
                    case ExportType.postman:
                      return _PostmanBody(
                        name: _nameController,
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

  String _obtainExportTypeName(ExportType type) {
    switch (type) {
      case ExportType.insomniaJson:
        return 'Insomnia (JSON)';
      case ExportType.restler:
        return 'Restler';
      case ExportType.postman:
        return 'Postman';
      default:
        return null;
    }
  }

  Future<ExportData> _onExport() async {
    return ExportData(
      _exportType.value,
      _passwordController.text,
      _nameController.text,
    );
  }
}

// Insomnia.

class _InsomniaBody extends StatefulWidget {
  const _InsomniaBody({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InsomniaBodyState();
  }
}

class _InsomniaBodyState extends State<_InsomniaBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[],
    );
  }
}

// Postman.

class _PostmanBody extends StatefulWidget {
  final TextEditingController name;

  const _PostmanBody({
    Key key,
    @required this.name,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Name.
        Flexible(
          child: TextField(
            controller: widget.name,
            decoration: InputDecoration(
              labelText: i18n.collectionName,
              hintText: i18n.appName,
            ),
            maxLength: 32,
          ),
        ),
      ],
    );
  }
}

// Restler.

class _RestlerBody extends StatefulWidget {
  final TextEditingController password;

  const _RestlerBody({
    Key key,
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
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
}
