import 'package:flutter/material.dart';
import 'package:restler/ui/widgets/item_menu_button.dart';

class TypeButton extends ItemMenuButton {
  TypeButton({
    String initialValue,
    PopupMenuItemSelected<String> onChanged,
  }) : super(
          initialValue: initialValue,
          items: ['rest', 'fcm'],
          onChanged: onChanged,
        );
}
