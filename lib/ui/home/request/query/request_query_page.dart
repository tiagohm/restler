import 'package:flutter/material.dart';
import 'package:restler/data/entities/query_entity.dart';
import 'package:restler/ui/home/request/query/query_item.dart';
import 'package:restler/ui/home/request/request_item.dart';
import 'package:restler/ui/widgets/list_page.dart';

class RequestQueryPage extends StatelessWidget {
  final List<QueryEntity> items;
  final VoidCallback onAdded;
  final ValueChanged<QueryEntity> onItemDuplicated;
  final ValueChanged<QueryEntity> onItemDeleted;
  final ValueChanged<QueryEntity> onItemChanged;

  const RequestQueryPage({
    Key key,
    @required this.items,
    this.onAdded,
    this.onItemChanged,
    this.onItemDeleted,
    this.onItemDuplicated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPage<QueryEntity>(
      items: items,
      onAdded: onAdded,
      itemBuilder: (context, index, item) {
        return QueryItem(
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
