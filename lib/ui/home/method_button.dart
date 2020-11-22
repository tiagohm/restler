import 'package:flutter/material.dart';
import 'package:restler/ui/widgets/context_menu_button.dart';
import 'package:restler/ui/widgets/item_menu_button.dart';

class MethodButton extends ItemMenuButton {
  MethodButton({
    String initialValue,
    PopupMenuItemSelected<String> onChanged,
  }) : super(
          initialValue: initialValue,
          items: [
            'GET',
            'POST',
            'PUT',
            'DELETE',
            'HEAD',
            'PATCH',
            'OPTIONS',
            'CUSTOM',
          ],
          onChanged: onChanged,
        );
}
