import 'package:flutter/material.dart';
import 'package:restler/data/entities/form_entity.dart';
import 'package:restler/ui/home/request/body/form_item.dart';
import 'package:restler/ui/home/request/request_item.dart';
import 'package:restler/ui/widgets/list_page.dart';

class RequestBodyFormPage extends StatefulWidget {
  final List<FormEntity> items;
  final VoidCallback onAdded;
  final ValueChanged<FormEntity> onItemDuplicated;
  final ValueChanged<FormEntity> onItemDeleted;
  final ValueChanged<FormEntity> onItemChanged;

  const RequestBodyFormPage({
    Key key,
    @required this.items,
    this.onAdded,
    this.onItemChanged,
    this.onItemDeleted,
    this.onItemDuplicated,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RequestBodyFormState();
  }
}

class _RequestBodyFormState extends State<RequestBodyFormPage> {
  @override
  Widget build(BuildContext context) {
    return ListPage<FormEntity>(
      items: widget.items,
      onAdded: widget.onAdded,
      itemBuilder: (context, index, item) {
        return FormItem(
          item: item,
          onItemChanged: widget.onItemChanged,
          onActionSelected: (action) {
            switch (action) {
              case RequestItemAction.delete:
                widget.onItemDeleted?.call(item);
                break;
              case RequestItemAction.duplicate:
                widget.onItemDuplicated?.call(item);
                break;
            }
          },
        );
      },
    );
  }
}
