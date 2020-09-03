import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restler/data/entities/dns_entity.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/label.dart';

enum DnsCardAction { edit, duplicate, move, copy, delete }

class DnsCard extends StatefulWidget {
  final DnsEntity dns;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<DnsCardAction> onActionSelected;

  const DnsCard({
    Key key,
    this.dns,
    this.onEnabled,
    this.onActionSelected,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DnsCardState();
  }
}

class _DnsCardState extends State<DnsCard> with StateMixin<DnsCard> {
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
              Icons.dns,
              color: Colors.white,
            ),
          ),
        ),
        // Address:Port or URL.
        title: Row(
          children: [
            Text(widget.dns.name ?? i18n.unnamed),
          ],
        ),
        // Value.
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Address or URL.
            if (widget.dns.https)
              Text(widget.dns.url)
            else
              Text('${widget.dns.address}:${widget.dns.port}'),
            Container(height: 4),
            Row(
              children: <Widget>[
                // HTTP or UDP.
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Label(
                    text: widget.dns.https ? 'HTTPS' : 'UDP',
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
              value: widget.dns.enabled,
              onChanged: widget.onEnabled,
            ),
            // Options.
            DotMenuButton<DnsCardAction>(
              items: const [
                DnsCardAction.edit,
                DnsCardAction.duplicate,
                DnsCardAction.move,
                DnsCardAction.copy,
                null, // Divider.
                DnsCardAction.delete,
              ],
              itemBuilder: (context, i, item) {
                return ListTile(
                  leading: Icon(_obtainDnsCardActionIcon(item)),
                  title: Text(_obtainDnsCardActionName(item)),
                );
              },
              onSelected: widget.onActionSelected,
            ),
          ],
        ),
      ),
    );
  }

  IconData _obtainDnsCardActionIcon(DnsCardAction action) {
    switch (action) {
      case DnsCardAction.edit:
        return Icons.edit;
      case DnsCardAction.duplicate:
        return Mdi.duplicate;
      case DnsCardAction.move:
        return Mdi.folderMove;
      case DnsCardAction.copy:
        return Icons.content_copy;
      case DnsCardAction.delete:
        return Icons.delete;
    }

    return null;
  }

  String _obtainDnsCardActionName(DnsCardAction action) {
    switch (action) {
      case DnsCardAction.edit:
        return i18n.edit;
      case DnsCardAction.duplicate:
        return i18n.duplicate;
      case DnsCardAction.move:
        return i18n.move;
      case DnsCardAction.copy:
        return i18n.copy;
      case DnsCardAction.delete:
        return i18n.delete;
    }

    return null;
  }
}
