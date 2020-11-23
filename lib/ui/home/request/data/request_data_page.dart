import 'package:flutter/material.dart';
import 'package:restler/data/entities/data_entity.dart';
import 'package:restler/ui/home/request/data/data_item.dart';
import 'package:restler/ui/home/request/request_item.dart';
import 'package:restler/ui/widgets/list_page.dart';

class RequestDataPage extends StatelessWidget {
  final List<DataEntity> items;
  final VoidCallback onAdded;
  final ValueChanged<DataEntity> onItemDuplicated;
  final ValueChanged<DataEntity> onItemDeleted;
  final ValueChanged<DataEntity> onItemChanged;

  const RequestDataPage({
    Key key,
    @required this.items,
    this.onAdded,
    this.onItemChanged,
    this.onItemDeleted,
    this.onItemDuplicated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPage<DataEntity>(
      items: items,
      onAdded: onAdded,
      itemBuilder: (context, index, item) {
        return DataItem(
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
