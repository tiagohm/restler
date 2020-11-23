import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/extensions.dart';
import 'package:restler/i18n.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';

enum CallCardAction { edit, move, duplicate, delete, copy }

class CallCard extends StatelessWidget {
  final CallEntity call;
  final ValueChanged<bool> onFavorited;
  final ValueChanged<CallCardAction> onActionSelected;
  final VoidCallback onTap;

  const CallCard({
    Key key,
    this.call,
    this.onFavorited,
    this.onActionSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        onTap: onTap,
        // Icon.
        leading: Container(
          width: 42,
          height: 42,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: call.request.isFCM
                ? Colors.orange
                : call.request.method.methodColor,
          ),
          child: Center(
            child: call.request.isFCM
                ? const Icon(Mdi.firebase)
                : Text(
                    call.request.method.shorten(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        // Name.
        title: Text(call.name),
        // URL.
        subtitle: Text(
          call.request.isFCM
              ? call.request.url.substring(0, min(32, call.request.url.length))
              : call.request.rightUrl,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
        trailing: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Favorite.
            IconButton(
              icon: Icon(
                Icons.star,
                color: call.favorite
                    ? Theme.of(context).indicatorColor
                    : Colors.grey,
              ),
              onPressed: () => onFavorited?.call(!call.favorite),
            ),
            // Options.
            DotMenuButton<CallCardAction>(
              items: const [
                CallCardAction.edit,
                CallCardAction.duplicate,
                CallCardAction.move,
                CallCardAction.copy,
                null, // Divider.
                CallCardAction.delete,
              ],
              itemBuilder: (context, i, item) {
                return ListTile(
                  leading: Icon(_obtainCallCardActionIcon(item)),
                  title: Text(_obtainCallCardActionName(context, item)),
                );
              },
              onSelected: onActionSelected,
            ),
          ],
        ),
      ),
    );
  }

  IconData _obtainCallCardActionIcon(CallCardAction action) {
    switch (action) {
      case CallCardAction.edit:
        return Icons.edit;
      case CallCardAction.move:
        return Mdi.folderMove;
      case CallCardAction.duplicate:
        return Mdi.duplicate;
      case CallCardAction.copy:
        return Icons.content_copy;
      case CallCardAction.delete:
        return Icons.delete;
    }

    return null;
  }

  String _obtainCallCardActionName(
    BuildContext context,
    CallCardAction action,
  ) {
    final i18n = I18n.of(context);

    switch (action) {
      case CallCardAction.edit:
        return i18n.edit;
      case CallCardAction.move:
        return i18n.move;
      case CallCardAction.duplicate:
        return i18n.duplicate;
      case CallCardAction.copy:
        return i18n.copy;
      case CallCardAction.delete:
        return i18n.delete;
    }

    return null;
  }
}
