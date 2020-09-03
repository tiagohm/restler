import 'package:flutter/services.dart';

class UppercaseFormatter implements TextInputFormatter {
  const UppercaseFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase(),
      selection: newValue.selection,
      composing: newValue.composing,
    );
  }
}
