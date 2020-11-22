import 'package:flutter/material.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/i18n.dart';

class FolderItem extends StatelessWidget {
  final FolderEntity item;

  const FolderItem({
    Key key,
    this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

    return Container(
      height: 32,
      width: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Todo o caminho da pasta-pai.
          if (!item.isRoot)
            Text(
              '${item.parent?.path(i18n.root) ?? i18n.root} /',
              style: TextStyle(
                fontSize: 9,
                color: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .color
                    .withOpacity(0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          // Nome da pasta.
          Text(
            item.name ?? i18n.root,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyText1.color,
            ),
          ),
        ],
      ),
    );
  }
}
