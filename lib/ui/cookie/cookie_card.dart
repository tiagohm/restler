import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restler/data/entities/cookie_entity.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

enum CookieCardAction { edit, duplicate, move, copy, delete }

class CookieCard extends StatefulWidget {
  final CookieEntity cookie;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<CookieCardAction> onActionSelected;

  const CookieCard({
    Key key,
    this.cookie,
    this.onEnabled,
    this.onActionSelected,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CookieCardState();
  }
}

class _CookieCardState extends State<CookieCard> with StateMixin<CookieCard> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        // Icon.
        leading: Container(
          width: 42,
          height: 42,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          child: const Center(
            child: Icon(
              Mdi.cookie,
              color: Colors.white,
            ),
          ),
        ),
        // Domain.
        title: Row(
          children: [
            Text(widget.cookie.domain ?? ''),
          ],
        ),
        // Value.
        subtitle: Text(
          widget.cookie.toCookieString(),
          softWrap: true,
          style: const TextStyle(
            fontSize: 11,
          ),
        ),
        trailing: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enable.
            Checkbox(
              value: widget.cookie.enabled,
              onChanged: widget.onEnabled,
            ),
            // Options.
            DotMenuButton<CookieCardAction>(
              items: const [
                CookieCardAction.edit,
                CookieCardAction.duplicate,
                CookieCardAction.move,
                CookieCardAction.copy,
                null, // Divider.
                CookieCardAction.delete,
              ],
              itemBuilder: (context, i, item) {
                return ListTile(
                  leading: Icon(_obtainCookieCardActionIcon(item)),
                  title: Text(_obtainCookieCardActionName(item)),
                );
              },
              onSelected: widget.onActionSelected,
            ),
          ],
        ),
      ),
    );
  }

  IconData _obtainCookieCardActionIcon(CookieCardAction action) {
    switch (action) {
      case CookieCardAction.edit:
        return Icons.edit;
      case CookieCardAction.duplicate:
        return Mdi.duplicate;
      case CookieCardAction.move:
        return Mdi.folderMove;
      case CookieCardAction.copy:
        return Icons.content_copy;
      case CookieCardAction.delete:
        return Icons.delete;
    }

    return null;
  }

  String _obtainCookieCardActionName(CookieCardAction action) {
    switch (action) {
      case CookieCardAction.edit:
        return i18n.edit;
      case CookieCardAction.duplicate:
        return i18n.duplicate;
      case CookieCardAction.move:
        return i18n.move;
      case CookieCardAction.copy:
        return i18n.copy;
      case CookieCardAction.delete:
        return i18n.delete;
    }

    return null;
  }
}
