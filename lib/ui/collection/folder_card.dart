import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/i18n.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';

enum FolderCardAction { edit, move, import, delete }

class FolderCard extends StatelessWidget {
  final FolderEntity folder;
  final ValueChanged<bool> onFavorited;
  final ValueChanged<FolderCardAction> onActionSelected;
  final void Function() onTap;

  const FolderCard({
    Key key,
    this.folder,
    this.onFavorited,
    this.onActionSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

    return Material(
      child: ListTile(
        onTap: onTap,
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
              Icons.folder,
              color: Colors.white,
            ),
          ),
        ),
        // Name.
        title: Text(folder.name),
        // Info.
        subtitle: Text(
          '${i18n.callCount(folder.numberOfCalls)} | ${i18n.folderCount(folder.numberOfFolders)}',
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
        trailing: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Favorite.
            IconButton(
              icon: Icon(
                Icons.star,
                color: folder.favorite
                    ? Theme.of(context).indicatorColor
                    : Colors.grey,
              ),
              onPressed: () => onFavorited?.call(!folder.favorite),
            ),
            // Options.
            DotMenuButton<FolderCardAction>(
              items: const [
                FolderCardAction.edit,
                FolderCardAction.move,
                FolderCardAction.import,
                null, // Divider.
                FolderCardAction.delete,
              ],
              itemBuilder: (context, i, item) {
                return ListTile(
                  leading: Icon(_obtainFolderCardActionIcon(item)),
                  title: Text(_obtainFolderCardActionName(context, item)),
                );
              },
              onSelected: onActionSelected,
            ),
          ],
        ),
      ),
    );
  }

  IconData _obtainFolderCardActionIcon(FolderCardAction action) {
    switch (action) {
      case FolderCardAction.edit:
        return Icons.edit;
      case FolderCardAction.move:
        return Mdi.folderMove;
      case FolderCardAction.delete:
        return Icons.delete;
      case FolderCardAction.import:
        return Mdi.import;
    }

    return null;
  }

  String _obtainFolderCardActionName(
    BuildContext context,
    FolderCardAction action,
  ) {
    final i18n = I18n.of(context);

    switch (action) {
      case FolderCardAction.edit:
        return i18n.edit;
      case FolderCardAction.move:
        return i18n.move;
      case FolderCardAction.delete:
        return i18n.delete;
      case FolderCardAction.import:
        return i18n.import;
    }

    return null;
  }
}
