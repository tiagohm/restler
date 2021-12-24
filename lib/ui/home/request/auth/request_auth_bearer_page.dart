import 'package:flutter/material.dart';
import 'package:restler/helper.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class RequestAuthBearerPage extends StatefulWidget {
  final String token;
  final String prefix;
  final ValueChanged<String> onTokenChanged;
  final ValueChanged<String> onPrefixChanged;

  const RequestAuthBearerPage({
    Key key,
    @required this.token,
    @required this.prefix,
    this.onTokenChanged,
    this.onPrefixChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RequestAuthBearerState();
  }
}

class _RequestAuthBearerState extends State<RequestAuthBearerPage>
    with StateMixin<RequestAuthBearerPage> {
  TextEditingController _tokenController;
  TextEditingController _prefixController;

  @override
  void initState() {
    _tokenController = TextEditingController(text: widget.token);
    _prefixController = TextEditingController(text: widget.prefix);
    super.initState();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _prefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      children: [
        // Token.
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: PowerfulTextField(
            controller: _tokenController,
            hintText: i18n.token,
            style: defaultInputTextStyle,
            onChanged: widget.onTokenChanged,
            suggestionsCallback: variableSuggestions,
          ),
        ),
        // Prefix.
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: PowerfulTextField(
            controller: _prefixController,
            hintText: i18n.prefix,
            style: defaultInputTextStyle,
            onChanged: widget.onPrefixChanged,
            suggestionsCallback: variableSuggestions,
          ),
        ),
      ],
    );
  }
}
