import 'package:flutter/material.dart';
import 'package:restler/i18n.dart';

const defaultInputTextStyle = TextStyle(
  fontFamily: 'monospace',
  fontSize: 14,
);

const defaultTableTextStyle = TextStyle(
  fontFamily: 'monospace',
  fontSize: 12,
  fontWeight: FontWeight.bold,
);

Widget charCounter(
  BuildContext context, {
  int currentLength,
  int maxLength,
  bool isFocused,
}) {
  return Text(
    I18n.of(context).charCount(currentLength),
    style: TextStyle(
      fontSize: 12,
      color: isFocused ? Theme.of(context).indicatorColor : null,
    ),
  );
}
