import 'package:flutter/material.dart';
import 'package:restler/data/entities/multipart_entity.dart';
import 'package:restler/ui/home/request/body/multipart_item.dart';
import 'package:restler/ui/widgets/list_page.dart';

class RequestBodyMultipartPage extends StatelessWidget {
  final List<MultipartEntity> items;
  final VoidCallback onAdded;
  final ValueChanged<MultipartEntity> onItemDuplicated;
  final ValueChanged<MultipartEntity> onItemDeleted;
  final ValueChanged<MultipartEntity> onItemChanged;

  const RequestBodyMultipartPage({
    Key key,
    @required this.items,
    this.onAdded,
    this.onItemChanged,
    this.onItemDeleted,
    this.onItemDuplicated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPage<MultipartEntity>(
      items: items,
      onAdded: onAdded,
      itemBuilder: (context, index, item) {
        return MultipartItem(
          item: item,
          onItemChanged: onItemChanged,
          onActionSelected: (action) {
            switch (action) {
              case MultipartItemAction.delete:
                onItemDeleted?.call(item);
                break;
              case MultipartItemAction.duplicate:
                onItemDuplicated?.call(item);
                break;
              default:
                break;
            }
          },
        );
      },
    );
  }
}
