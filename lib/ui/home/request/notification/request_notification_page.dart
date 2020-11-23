import 'package:flutter/material.dart';
import 'package:restler/data/entities/notification_entity.dart';
import 'package:restler/ui/home/request/notification/notification_item.dart';
import 'package:restler/ui/home/request/request_item.dart';
import 'package:restler/ui/widgets/list_page.dart';

class RequestNotificationPage extends StatelessWidget {
  final List<NotificationEntity> items;
  final VoidCallback onAdded;
  final ValueChanged<NotificationEntity> onItemDuplicated;
  final ValueChanged<NotificationEntity> onItemDeleted;
  final ValueChanged<NotificationEntity> onItemChanged;

  const RequestNotificationPage({
    Key key,
    @required this.items,
    this.onAdded,
    this.onItemChanged,
    this.onItemDeleted,
    this.onItemDuplicated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPage<NotificationEntity>(
      items: items,
      onAdded: onAdded,
      itemBuilder: (context, index, item) {
        return NotificationItem(
          item: item,
          onItemChanged: onItemChanged,
          onActionSelected: (action) {
            switch (action) {
              case RequestItemAction.delete:
                onItemDeleted?.call(item);
                break;
              case RequestItemAction.duplicate:
                onItemDuplicated?.call(item);
                break;
            }
          },
        );
      },
    );
  }
}
