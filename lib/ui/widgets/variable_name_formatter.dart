import 'package:flutter/services.dart';

class VariableNameFormatter implements TextInputFormatter {
  const VariableNameFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = clear(newValue.text) ?? '';

    return TextEditingValue(
      text: text,
      selection:
          TextSelection(baseOffset: text.length, extentOffset: text.length),
      composing: TextRange(start: 0, end: text.length),
    );
  }

  static const _invalidChars = '{} ';

  static String clear(String text) {
    if (text == null || text.isEmpty) {
      return text;
    }

    final sb = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final c = text[i];
      if (!_invalidChars.contains(c)) {
        sb.write(c);
      }
    }

    return sb.toString();
  }
}
