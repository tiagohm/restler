import 'package:flutter/material.dart';
import 'package:restio/restio.dart';
import 'package:restler/data/entities/proxy_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class CreateEditProxyDialog extends StatefulWidget {
  final ProxyEntity proxy;

  const CreateEditProxyDialog(this.proxy);

  static Future<DialogResult<ProxyEntity>> show(
    BuildContext context,
    ProxyEntity proxy,
  ) async {
    return showDialog<DialogResult<ProxyEntity>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateEditProxyDialog(proxy),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return CreateOrEditProxyState();
  }
}

class CreateOrEditProxyState extends State<CreateEditProxyDialog>
    with StateMixin<CreateEditProxyDialog> {
  TextEditingController _nameTextController;
  TextEditingController _hostTextController;
  TextEditingController _portTextController;
  TextEditingController _usernameTextController;
  TextEditingController _passwordTextController;
  bool _http;
  bool _https;
  bool _auth;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _nameTextController = TextEditingController(text: widget.proxy?.name ?? '');
    _hostTextController = TextEditingController(text: widget.proxy?.host ?? '');
    _portTextController =
        TextEditingController(text: widget.proxy?.port?.toString() ?? '');
    _usernameTextController =
        TextEditingController(text: widget.proxy?.auth?.username ?? '');
    _passwordTextController =
        TextEditingController(text: widget.proxy?.auth?.password ?? '');
    _http = widget.proxy?.http ?? true;
    _https = widget.proxy?.https ?? true;
    _auth = widget.proxy?.auth != null;

    super.initState();
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _hostTextController.dispose();
    _portTextController.dispose();
    _usernameTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<ProxyEntity>(
      doneText: i18n.save,
      title: widget.proxy == null ? i18n.newProxy : i18n.editProxy,
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
                // Proxy type.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // HTTP.
                    Checkbox(
                      value: _http,
                      onChanged: (enabled) {
                        setState(() {
                          _http = enabled;
                        });
                      },
                    ),
                    const Text(
                      'HTTP',
                      style: defaultInputTextStyle,
                    ),
                    // HTTPS.
                    Checkbox(
                      value: _https,
                      onChanged: (enabled) {
                        setState(() {
                          _https = enabled;
                        });
                      },
                    ),
                    const Text(
                      'HTTPS',
                      style: defaultInputTextStyle,
                    ),
                  ],
                ),
                // Host.
                TextFormField(
                  controller: _hostTextController,
                  validator: textIsRequired,
                  decoration: const InputDecoration(labelText: 'Host'),
                  style: defaultInputTextStyle,
                ),
                // Port.
                TextFormField(
                  controller: _portTextController,
                  validator: textIsRequired,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: i18n.port),
                  style: defaultInputTextStyle,
                ),
                // Auth.
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _auth,
                      onChanged: (enabled) {
                        setState(() {
                          _auth = enabled;
                        });
                      },
                    ),
                    Text(
                      '${i18n.auth} (Basic Auth)',
                      style: defaultInputTextStyle,
                    ),
                  ],
                ),
                // Username.
                TextFormField(
                  controller: _usernameTextController,
                  enabled: _auth,
                  validator: (text) {
                    return _auth && text.isEmpty ? i18n.required : null;
                  },
                  decoration: InputDecoration(labelText: i18n.username),
                  style: defaultInputTextStyle,
                ),
                // Password.
                TextFormField(
                  controller: _passwordTextController,
                  enabled: _auth,
                  validator: (text) {
                    return _auth && text.isEmpty ? i18n.required : null;
                  },
                  decoration: InputDecoration(labelText: i18n.password),
                  obscureText: true,
                  style: defaultInputTextStyle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<ProxyEntity> _onSave() async {
    if (_formKey.currentState.validate()) {
      final name = _nameTextController.text.trim();
      final host = _hostTextController.text.trim();
      final port = _portTextController.text.trim();
      final username = _usernameTextController.text.trim();
      final password = _passwordTextController.text;
      final auth = _auth
          ? BasicAuthenticator(
              username: username,
              password: password,
            )
          : null;

      // Create.
      if (widget.proxy == null) {
        return ProxyEntity(
          uid: generateUuid(),
          name: name,
          host: host,
          port: port.isEmpty ? null : int.tryParse(port),
          http: _http,
          https: _https,
          auth: auth,
        );
      }
      // Edit.
      else {
        return ProxyEntity(
          uid: widget.proxy.uid,
          name: name,
          host: host,
          port: port.isEmpty ? null : int.tryParse(port),
          http: _http,
          https: _https,
          auth: auth,
          enabled: widget.proxy.enabled,
        );
      }
    } else {
      return null;
    }
  }
}
