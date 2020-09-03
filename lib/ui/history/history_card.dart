import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restler/data/entities/history_entity.dart';
import 'package:restler/extensions.dart';
import 'package:restler/i18n.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';
import 'package:restler/ui/widgets/label.dart';

enum HistoryCardAction { save, delete }

class HistoryCard extends StatelessWidget {
  final HistoryEntity history;
  final ValueChanged<HistoryCardAction> onActionSelected;
  final VoidCallback onTap;

  const HistoryCard({
    Key key,
    this.history,
    this.onActionSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

    return Material(
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        child: Center(
          child: ListTile(
            onTap: onTap,
            // Icon.
            leading: Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: history.request.method.methodColor,
              ),
              child: Center(
                child: Text(
                  history.request.method.shorten(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // URL.
            title: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                history.request.rightUrl,
                style: const TextStyle(
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Info.
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Date.
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    i18n.dateTimePattern(
                        DateTime.fromMillisecondsSinceEpoch(history.date)),
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, top: 4),
                  child: Row(
                    children: <Widget>[
                      Container(width: 4),
                      // Status.
                      Visibility(
                        visible: history.response.status > 0,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Label(
                            text: '${history.response.status}',
                            color: history.response.status.statusColor,
                          ),
                        ),
                      ),
                      // Size.
                      Visibility(
                        visible: history.response.size > 0,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Label(
                            text: '${history.response.size} B',
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      // Duration.
                      Visibility(
                        visible: history.response.time > 0,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Label(
                            text: '${history.response.time} ms',
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Options.
                DotMenuButton<HistoryCardAction>(
                  items: const [
                    HistoryCardAction.save,
                    null, // Divider.
                    HistoryCardAction.delete,
                  ],
                  itemBuilder: (context, i, item) {
                    return ListTile(
                      leading: Icon(_obtainHistoryCardActionIcon(item)),
                      title: Text(_obtainHistoryCardActionName(context, item)),
                    );
                  },
                  onSelected: onActionSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _obtainHistoryCardActionIcon(HistoryCardAction action) {
    switch (action) {
      case HistoryCardAction.save:
        return Icons.save;
      case HistoryCardAction.delete:
        return Icons.delete;
    }

    return null;
  }

  String _obtainHistoryCardActionName(
    BuildContext context,
    HistoryCardAction action,
  ) {
    final i18n = I18n.of(context);

    switch (action) {
      case HistoryCardAction.save:
        return i18n.save;
      case HistoryCardAction.delete:
        return i18n.delete;
    }

    return null;
  }
}
