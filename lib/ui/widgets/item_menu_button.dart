import 'package:flutter/material.dart';
import 'package:restler/ui/widgets/context_menu_button.dart';

class ItemMenuButton extends ContextMenuButton<String> {
  ItemMenuButton({
    String initialValue,
    @required List<String> items,
    PopupMenuItemSelected<String> onChanged,
  }) : super(
          initialValue: initialValue,
          items: items,
          itemBuilder: (context, index, item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: index == -1
                  ? Text(
                      item.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).indicatorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(item.replaceAll('_', ' ').toUpperCase()),
            );
          },
          onChanged: onChanged,
        );
}
