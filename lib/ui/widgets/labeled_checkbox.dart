import 'package:flutter/material.dart';
import 'package:restler/ui/constants.dart';

class LabeledCheckbox extends StatelessWidget {
  final bool value;
  final String text;
  final void Function(bool value) onChanged;

  const LabeledCheckbox({
    Key key,
    @required this.value,
    @required this.text,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Flexible(
          child: Text(
            text,
            style: defaultInputTextStyle,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
