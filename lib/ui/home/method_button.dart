import 'package:flutter/material.dart';
import 'package:restler/ui/widgets/context_menu_button.dart';

class MethodButton extends ContextMenuButton<String> {
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
          itemBuilder: (context, index, item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: index == -1
                  ? Text(
                      item,
                      style: TextStyle(
                        color: Theme.of(context).indicatorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(item),
            );
          },
          onChanged: onChanged,
        );
}
