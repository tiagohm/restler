import 'package:flutter/material.dart';
import 'package:restler/ui/widgets/context_menu_button.dart';

class SchemeButton extends ContextMenuButton<String> {
  SchemeButton({
    String initialValue,
    PopupMenuItemSelected<String> onChanged,
  }) : super(
          initialValue: initialValue,
          items: ['http', 'https', 'http2', 'auto'],
          itemBuilder: (context, index, item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: index == -1
                  ? Text(
                      item.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).indicatorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(item.toUpperCase()),
            );
          },
          onChanged: onChanged,
        );
}
