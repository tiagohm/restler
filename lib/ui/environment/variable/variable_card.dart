import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restler/data/entities/variable_entity.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

enum VariableCardAction { edit, duplicate, delete }

final _charRegex = RegExp('.');

class VariableCard extends StatefulWidget {
  final VariableEntity variable;
  final ValueChanged<VariableCardAction> onActionSelected;

  const VariableCard({
    Key key,
    this.variable,
    this.onActionSelected,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VariableCardState();
  }
}

class _VariableCardState extends State<VariableCard>
    with StateMixin<VariableCard> {
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
              Mdi.variable,
              color: Colors.white,
            ),
          ),
        ),
        // Name.
        title: Text(widget.variable.name),
        // Value.
        subtitle: widget.variable.secret
            ? Text(
                widget.variable.value.replaceAll(_charRegex, '●'),
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                widget.variable.value,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Options.
            DotMenuButton<VariableCardAction>(
              items: const [
                VariableCardAction.edit,
                VariableCardAction.duplicate,
                null, // Divider.
                VariableCardAction.delete,
              ],
              itemBuilder: (context, i, item) {
                return ListTile(
                  leading: Icon(_obtainVariableCardActionIcon(item)),
                  title: Text(_obtainVariableCardActionName(item)),
                );
              },
              onSelected: widget.onActionSelected,
            ),
          ],
        ),
      ),
    );
  }

  IconData _obtainVariableCardActionIcon(VariableCardAction action) {
    switch (action) {
      case VariableCardAction.edit:
        return Icons.edit;
      case VariableCardAction.duplicate:
        return Mdi.duplicate;
      case VariableCardAction.delete:
        return Icons.delete;
    }

    return null;
  }

  String _obtainVariableCardActionName(VariableCardAction action) {
    switch (action) {
      case VariableCardAction.edit:
        return i18n.edit;
      case VariableCardAction.duplicate:
        return i18n.duplicate;
      case VariableCardAction.delete:
        return i18n.delete;
    }

    return null;
  }
}
