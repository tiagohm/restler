import 'package:flutter/material.dart';
import 'package:restler/ui/widgets/item_menu_button.dart';

class SchemeButton extends ItemMenuButton {
  SchemeButton({
    String initialValue,
    PopupMenuItemSelected<String> onChanged,
  }) : super(
          initialValue: initialValue,
          items: ['http', 'https', 'http2', 'auto'],
          onChanged: onChanged,
        );
}
