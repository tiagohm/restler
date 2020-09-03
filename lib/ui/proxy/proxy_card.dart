import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restler/data/entities/proxy_entity.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/label.dart';

enum ProxyCardAction { edit, duplicate, move, copy, delete }

class ProxyCard extends StatefulWidget {
  final ProxyEntity proxy;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<ProxyCardAction> onActionSelected;

  const ProxyCard({
    Key key,
    this.proxy,
    this.onEnabled,
    this.onActionSelected,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProxyCardState();
  }
}

class _ProxyCardState extends State<ProxyCard> with StateMixin<ProxyCard> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        isThreeLine: true,
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
              Mdi.serverNetwork,
              color: Colors.white,
            ),
          ),
        ),
        // Host.
        title: Row(
          children: [
            Text(widget.proxy.name ?? i18n.unnamed),
          ],
        ),
        // Value.
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // URL.
            Row(
              children: <Widget>[
                if (widget.proxy.host != null) Text(widget.proxy.host),
                if (widget.proxy.port != null) Text(':${widget.proxy.port}'),
              ],
            ),
            Container(height: 4),
            Row(
              children: <Widget>[
                // HTTP.
                if (widget.proxy.http == true)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Label(
                      text: 'HTTP',
                      color: Colors.blue,
                    ),
                  ),
                // KEY.
                if (widget.proxy.https == true)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Label(
                      text: 'HTTPS',
                      color: Colors.blue,
                    ),
                  ),
                // AUTH.
                if (widget.proxy.auth != null)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Label(
                      text: 'AUTH',
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enable.
            Checkbox(
              value: widget.proxy.enabled,
              onChanged: widget.onEnabled,
            ),
            // Options.
            DotMenuButton<ProxyCardAction>(
              items: const [
                ProxyCardAction.edit,
                ProxyCardAction.duplicate,
                ProxyCardAction.move,
                ProxyCardAction.copy,
                null, // Divider.
                ProxyCardAction.delete,
              ],
              itemBuilder: (context, i, item) {
                return ListTile(
                  leading: Icon(_obtainProxyCardActionIcon(item)),
                  title: Text(_obtainProxyCardActionName(item)),
                );
              },
              onSelected: widget.onActionSelected,
            ),
          ],
        ),
      ),
    );
  }

  IconData _obtainProxyCardActionIcon(ProxyCardAction action) {
    switch (action) {
      case ProxyCardAction.edit:
        return Icons.edit;
      case ProxyCardAction.duplicate:
        return Mdi.duplicate;
      case ProxyCardAction.move:
        return Mdi.folderMove;
      case ProxyCardAction.copy:
        return Icons.content_copy;
      case ProxyCardAction.delete:
        return Icons.delete;
    }

    return null;
  }

  String _obtainProxyCardActionName(ProxyCardAction action) {
    switch (action) {
      case ProxyCardAction.edit:
        return i18n.edit;
      case ProxyCardAction.duplicate:
        return i18n.duplicate;
      case ProxyCardAction.move:
        return i18n.move;
      case ProxyCardAction.copy:
        return i18n.copy;
      case ProxyCardAction.delete:
        return i18n.delete;
    }

    return null;
  }
}
