import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

enum EnvironmentCardAction { edit, duplicate, move, copy, delete }

class EnvironmentCard extends StatefulWidget {
  final EnvironmentEntity environment;
  final ValueChanged<EnvironmentCardAction> onActionSelected;
  final VoidCallback onTap;

  const EnvironmentCard({
    Key key,
    this.environment,
    this.onActionSelected,
    this.onTap,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EnvironmentCardState();
  }
}

class _EnvironmentCardState extends State<EnvironmentCard>
    with StateMixin<EnvironmentCard> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        onTap: widget.onTap,
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
              Mdi.environment,
              color: Colors.white,
            ),
          ),
        ),
        // Name.
        title: Row(
          children: [
            Text(widget.environment.name ?? i18n.global),
          ],
        ),
        trailing: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.environment.isGlobal)
              // Options.
              DotMenuButton<EnvironmentCardAction>(
                items: const [
                  EnvironmentCardAction.edit,
                  EnvironmentCardAction.duplicate,
                  EnvironmentCardAction.move,
                  EnvironmentCardAction.copy,
                  null, // Divider.
                  EnvironmentCardAction.delete,
                ],
                itemBuilder: (context, i, item) {
                  return ListTile(
                    leading: Icon(_obtainEnvironmentCardActionIcon(item)),
                    title: Text(_obtainEnvironmentCardActionName(item)),
                  );
                },
                onSelected: widget.onActionSelected,
              ),
          ],
        ),
      ),
    );
  }

  IconData _obtainEnvironmentCardActionIcon(EnvironmentCardAction action) {
    switch (action) {
      case EnvironmentCardAction.edit:
        return Icons.edit;
      case EnvironmentCardAction.duplicate:
        return Mdi.duplicate;
      case EnvironmentCardAction.move:
        return Mdi.folderMove;
      case EnvironmentCardAction.copy:
        return Icons.content_copy;
      case EnvironmentCardAction.delete:
        return Icons.delete;
    }

    return null;
  }

  String _obtainEnvironmentCardActionName(EnvironmentCardAction action) {
    switch (action) {
      case EnvironmentCardAction.edit:
        return i18n.edit;
      case EnvironmentCardAction.duplicate:
        return i18n.duplicate;
      case EnvironmentCardAction.move:
        return i18n.move;
      case EnvironmentCardAction.copy:
        return i18n.copy;
      case EnvironmentCardAction.delete:
        return i18n.delete;
    }

    return null;
  }
}
