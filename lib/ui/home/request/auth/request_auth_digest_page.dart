import 'package:flutter/material.dart';
import 'package:restler/helper.dart';
import 'package:restler/i18n.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

class RequestAuthDigestPage extends StatefulWidget {
  final String username;
  final String password;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onPasswordChanged;

  const RequestAuthDigestPage({
    Key key,
    @required this.username,
    @required this.password,
    this.onUsernameChanged,
    this.onPasswordChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RequestAuthDigestState();
  }
}

class _RequestAuthDigestState extends State<RequestAuthDigestPage> {
  TextEditingController _usernameController;
  TextEditingController _passwordController;

  @override
  void initState() {
    _usernameController = TextEditingController(text: widget.username);
    _passwordController = TextEditingController(text: widget.password);
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView(
        shrinkWrap: true,
        children: [
          // Username.
          ListTile(
            title: PowerfulTextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: i18n.username,
              ),
              style: defaultInputTextStyle,
              onChanged: widget.onUsernameChanged,
              suggestionsCallback: variableSuggestions,
            ),
          ),
          // Password.
          ListTile(
            title: PowerfulTextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: i18n.password,
              ),
              style: defaultInputTextStyle,
              onChanged: widget.onPasswordChanged,
              isPassword: true,
            ),
          ),
        ],
      ),
    );
  }
}
