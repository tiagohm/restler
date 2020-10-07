import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:restler/data/entities/certificate_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

class CreateEditCertificateDialog extends StatefulWidget {
  final CertificateEntity certificate;

  const CreateEditCertificateDialog(this.certificate);

  static Future<DialogResult<CertificateEntity>> show(
    BuildContext context,
    CertificateEntity certificate,
  ) async {
    return showDialog<DialogResult<CertificateEntity>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateEditCertificateDialog(certificate),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return CreateOrEditCertificateState();
  }
}

class CreateOrEditCertificateState extends State<CreateEditCertificateDialog>
    with StateMixin<CreateEditCertificateDialog> {
  TextEditingController _hostTextController;
  TextEditingController _portTextController;
  TextEditingController _crtTextController;
  TextEditingController _keyTextController;
  TextEditingController _passphraseTextController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _hostTextController =
        TextEditingController(text: widget.certificate?.host ?? '');
    _portTextController =
        TextEditingController(text: widget.certificate?.port?.toString() ?? '');
    _crtTextController =
        TextEditingController(text: widget.certificate?.crt ?? '');
    _keyTextController =
        TextEditingController(text: widget.certificate?.key ?? '');
    _passphraseTextController =
        TextEditingController(text: widget.certificate?.passphrase ?? '');

    super.initState();
  }

  @override
  void dispose() {
    _hostTextController.dispose();
    _crtTextController.dispose();
    _keyTextController.dispose();
    _passphraseTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<CertificateEntity>(
      doneText: i18n.save,
      title: widget.certificate == null
          ? i18n.newCertificate
          : i18n.editCertificate,
      onDone: _onSave,
      bodyBuilder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 4),
          child: Form(
            key: _formKey,
            child: ListBody(
              children: [
                // Host.
                TextFormField(
                  controller: _hostTextController,
                  validator: textIsRequired,
                  decoration: InputDecoration(labelText: i18n.host),
                  style: defaultInputTextStyle,
                ),
                // Port.
                TextFormField(
                  controller: _portTextController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: i18n.port),
                  style: defaultInputTextStyle,
                ),
                // CRT.
                TextFormField(
                  controller: _crtTextController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'CRT'),
                  style: defaultInputTextStyle,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton.icon(
                      icon: const Icon(Mdi.file),
                      label: Text(i18n.chooseFile),
                      onPressed: _onChooseCrt,
                      color: Colors.orange,
                    ),
                  ],
                ),
                // KEY.
                TextFormField(
                  controller: _keyTextController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'KEY'),
                  style: defaultInputTextStyle,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton.icon(
                      icon: const Icon(Mdi.file),
                      label: Text(i18n.chooseFile),
                      onPressed: _onChooseKey,
                      color: Colors.orange,
                    ),
                  ],
                ),
                // Passphrase.
                PowerfulTextField(
                  controller: _passphraseTextController,
                  decoration: InputDecoration(labelText: i18n.passphrase),
                  style: defaultInputTextStyle,
                  isPassword: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<CertificateEntity> _onSave() async {
    if (_formKey.currentState.validate()) {
      final host = _hostTextController.text.trim();
      final port = _portTextController.text.trim();
      final crt = _crtTextController.text;
      final key = _keyTextController.text.trim();
      final passphrase = _passphraseTextController.text;

      // Create.
      if (widget.certificate == null) {
        return CertificateEntity(
          uid: generateUuid(),
          host: host,
          port: port.isEmpty ? null : int.tryParse(port),
          crt: crt,
          key: key,
          passphrase: passphrase,
        );
      }
      // Edit.
      else {
        return CertificateEntity(
          uid: widget.certificate.uid,
          host: host,
          port: port.isEmpty ? null : int.tryParse(port),
          crt: crt,
          key: key,
          passphrase: passphrase,
          enabled: widget.certificate.enabled,
        );
      }
    } else {
      return null;
    }
  }

  Future<void> _onChooseCrt() async {
    final res = await FilePicker.platform.pickFiles();

    if (res != null && res.files.isNotEmpty) {
      _crtTextController.text = res.paths[0];
    }
  }

  Future<void> _onChooseKey() async {
    final res = await FilePicker.platform.pickFiles();

    if (res != null && res.files.isNotEmpty) {
      _keyTextController.text = res.paths[0];
    }
  }
}
