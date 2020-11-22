import 'package:flutter/material.dart';
import 'package:restler/data/entities/target_entity.dart';
import 'package:restler/ui/home/request/request_item.dart';
import 'package:restler/ui/home/request/target/target_item.dart';
import 'package:restler/ui/widgets/list_page.dart';

class RequestTargetPage extends StatelessWidget {
  final List<TargetEntity> items;
  final VoidCallback onAdded;
  final ValueChanged<TargetEntity> onItemDuplicated;
  final ValueChanged<TargetEntity> onItemDeleted;
  final ValueChanged<TargetEntity> onItemChanged;

  const RequestTargetPage({
    Key key,
    @required this.items,
    this.onAdded,
    this.onItemChanged,
    this.onItemDeleted,
    this.onItemDuplicated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPage<TargetEntity>(
      items: items,
      onAdded: onAdded,
      itemBuilder: (context, index, item) {
        return TargetItem(
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
