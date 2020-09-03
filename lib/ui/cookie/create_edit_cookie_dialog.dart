import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restler/data/entities/cookie_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class CreateEditCookieDialog extends StatefulWidget {
  final CookieEntity cookie;

  const CreateEditCookieDialog(this.cookie);

  static Future<DialogResult<CookieEntity>> show(
    BuildContext context,
    CookieEntity cookie,
  ) async {
    return showDialog<DialogResult<CookieEntity>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateEditCookieDialog(cookie),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return CreateOrEditCookieState();
  }
}

class CreateOrEditCookieState extends State<CreateEditCookieDialog>
    with StateMixin<CreateEditCookieDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameTextController;
  TextEditingController _valueTextController;
  TextEditingController _domainTextController;
  TextEditingController _pathTextController;
  DateTime _expiresDateTime;
  bool _isSecure;
  bool _isHttpOnly;

  @override
  void initState() {
    _nameTextController =
        TextEditingController(text: widget.cookie?.name ?? '');
    _valueTextController =
        TextEditingController(text: widget.cookie?.value ?? '');
    _domainTextController =
        TextEditingController(text: widget.cookie?.domain ?? '');
    _pathTextController =
        TextEditingController(text: widget.cookie?.path ?? '');
    _expiresDateTime =
        widget.cookie?.expires != null ? widget.cookie.expires : null;
    _isSecure = widget.cookie?.secure ?? false;
    _isHttpOnly = widget.cookie?.httpOnly ?? false;

    super.initState();
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _valueTextController.dispose();
    _domainTextController.dispose();
    _pathTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<CookieEntity>(
      doneText: i18n.save,
      title: widget.cookie == null ? i18n.newCookie : i18n.editCookie,
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
                // Value.
                TextFormField(
                  controller: _valueTextController,
                  decoration: InputDecoration(labelText: i18n.value),
                  style: defaultInputTextStyle,
                ),
                // Domain.
                TextFormField(
                  controller: _domainTextController,
                  validator: textIsRequired,
                  decoration: InputDecoration(labelText: i18n.domain),
                  style: defaultInputTextStyle,
                ),
                // Path.
                TextFormField(
                  controller: _pathTextController,
                  decoration: InputDecoration(
                    labelText: i18n.path,
                    hintText: '/',
                  ),
                  style: defaultInputTextStyle,
                ),
                // Expires.
                DateTimeField(
                  initialValue: _expiresDateTime?.toLocal(),
                  // Thu, 1 Jan 1970 00:00:00 GMT
                  format: DateFormat('EEE, dd MMM yyyy HH:mm:ss'),
                  decoration: const InputDecoration(
                    labelText: 'Expires',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  onChanged: (datetime) => _expiresDateTime = datetime,
                  style: defaultInputTextStyle,
                  onShowPicker: (context, currentDate) async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentDate ?? DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(date),
                      );

                      if (time != null) {
                        return DateTimeField.combine(date, time);
                      } else {
                        return date;
                      }
                    } else {
                      return date;
                    }
                  },
                ),
                // Secure.
                Row(
                  children: [
                    Checkbox(
                      value: _isSecure,
                      onChanged: (value) => setState(() => _isSecure = value),
                    ),
                    const Text(
                      'Secure',
                      style: defaultInputTextStyle,
                    ),
                  ],
                ),
                // Http Only.
                Row(
                  children: [
                    Checkbox(
                      value: _isHttpOnly,
                      onChanged: (value) => setState(() => _isHttpOnly = value),
                    ),
                    const Text(
                      'Http Only',
                      style: defaultInputTextStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<CookieEntity> _onSave() async {
    if (_formKey.currentState.validate()) {
      final path = _pathTextController.text.trim();
      final domain = _domainTextController.text.trim();
      final name = _nameTextController.text.trim();
      final value = _valueTextController.text;
      final expires = _expiresDateTime?.toUtc();

      // Create.
      if (widget.cookie == null) {
        return CookieEntity(
          uid: generateUuid(),
          timestamp: currentMillis(),
          name: name,
          value: value,
          expires: expires,
          domain: domain,
          path: path.startsWith('/') ? path : '/$path',
          secure: _isSecure,
          httpOnly: _isHttpOnly,
        );
      }
      // Edit.
      else {
        return CookieEntity(
          uid: widget.cookie.uid,
          timestamp: widget.cookie.timestamp,
          enabled: widget.cookie.enabled,
          name: name,
          value: value,
          expires: expires,
          domain: domain,
          path: path.startsWith('/') ? path : '/$path',
          secure: _isSecure,
          httpOnly: _isHttpOnly,
        );
      }
    } else {
      return null;
    }
  }
}
