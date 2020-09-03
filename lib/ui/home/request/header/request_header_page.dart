import 'package:flutter/material.dart';
import 'package:restler/data/entities/header_entity.dart';
import 'package:restler/ui/home/request/header/header_item.dart';
import 'package:restler/ui/home/request/request_item.dart';
import 'package:restler/ui/widgets/list_page.dart';

class RequestHeaderPage extends StatelessWidget {
  final List<HeaderEntity> items;
  final VoidCallback onAdded;
  final ValueChanged<HeaderEntity> onItemDuplicated;
  final ValueChanged<HeaderEntity> onItemDeleted;
  final ValueChanged<HeaderEntity> onItemChanged;

  const RequestHeaderPage({
    Key key,
    @required this.items,
    this.onAdded,
    this.onItemChanged,
    this.onItemDeleted,
    this.onItemDuplicated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPage<HeaderEntity>(
      items: items,
      onAdded: onAdded,
      itemBuilder: (context, index, item) {
        return HeaderItem(
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
