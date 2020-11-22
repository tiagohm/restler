import 'package:flutter/material.dart';
import 'package:restio/restio.dart';
import 'package:restler/helper.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/context_menu_button.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

class RequestAuthHawkPage extends StatefulWidget {
  final String id;
  final String hkey;
  final HawkAlgorithm algorithm;
  final String ext;
  final ValueChanged<String> onIdChanged;
  final ValueChanged<String> onKeyChanged;
  final ValueChanged<HawkAlgorithm> onAlgorithmChanged;
  final ValueChanged<String> onExtChanged;

  const RequestAuthHawkPage({
    @required this.id,
    @required this.hkey,
    @required this.algorithm,
    @required this.ext,
    this.onIdChanged,
    this.onKeyChanged,
    this.onAlgorithmChanged,
    this.onExtChanged,
  });

  @override
  State<StatefulWidget> createState() {
    return _RequestAuthHawkState();
  }
}

class _RequestAuthHawkState extends State<RequestAuthHawkPage>
    with StateMixin<RequestAuthHawkPage> {
  TextEditingController _idController;
  TextEditingController _keyController;
  TextEditingController _algorithmController;
  TextEditingController _extController;

  @override
  void initState() {
    _idController = TextEditingController(text: widget.id);
    _keyController = TextEditingController(text: widget.hkey);
    _algorithmController =
        TextEditingController(text: _obtainHawkAlgorithmName(widget.algorithm));
    _extController = TextEditingController(text: widget.ext);
    super.initState();
  }

  @override
  void dispose() {
    _idController.dispose();
    _keyController.dispose();
    _algorithmController.dispose();
    _extController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView(
        shrinkWrap: true,
        children: [
          // Id.
          ListTile(
            title: PowerfulTextField(
              controller: _idController,
              hintText: i18n.id,
              style: defaultInputTextStyle,
              onChanged: widget.onIdChanged,
              suggestionsCallback: variableSuggestions,
            ),
          ),
          // Key.
          ListTile(
            title: PowerfulTextField(
              controller: _keyController,
              hintText: i18n.key,
              style: defaultInputTextStyle,
              onChanged: widget.onKeyChanged,
              suggestionsCallback: variableSuggestions,
            ),
          ),
          // Ext.
          ListTile(
            title: PowerfulTextField(
              controller: _extController,
              hintText: i18n.ext,
              style: defaultInputTextStyle,
              onChanged: widget.onExtChanged,
              suggestionsCallback: variableSuggestions,
            ),
          ),
          // Algorithm.
          ListTile(
            title: ContextMenuButton<HawkAlgorithm>(
              items: HawkAlgorithm.values,
              itemBuilder: (context, index, item) {
                if (index == -1) {
                  return TextField(
                    controller: _algorithmController,
                    enabled: false,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: i18n.algorithm,
                    ),
                    style: defaultInputTextStyle,
                  );
                } else {
                  return Text(
                    _obtainHawkAlgorithmName(item),
                    style: defaultInputTextStyle,
                  );
                }
              },
              onChanged: (algorithm) {
                widget.onAlgorithmChanged?.call(algorithm);
                _algorithmController.text = _obtainHawkAlgorithmName(algorithm);
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _obtainHawkAlgorithmName(HawkAlgorithm algorithm) {
    return algorithm == HawkAlgorithm.sha1 ? 'SHA-1' : 'SHA-256';
  }
}
