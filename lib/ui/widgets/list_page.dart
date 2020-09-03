import 'package:flutter/material.dart';
import 'package:restler/i18n.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/widgets/empty.dart';

class ListPage<T> extends StatelessWidget {
  final List<T> items;
  final VoidCallback onAdded;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final IconData emptyIcon;
  final String emptyText;
  final IconData addIcon;

  const ListPage({
    Key key,
    @required this.items,
    this.onAdded,
    this.itemBuilder,
    this.emptyIcon,
    this.emptyText,
    this.addIcon = Icons.add,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // List.
        _buildItems(context, items),
        // Add.
        if (onAdded != null)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 0,
              onPressed: onAdded,
              child: Icon(addIcon),
            ),
          ),
      ],
    );
  }

  Widget _buildItems(
    BuildContext context,
    List<T> data,
  ) {
    if (data.isEmpty) {
      return _buildEmptyItems(context);
    } else {
      return _buildNonEmptyItems(context, data);
    }
  }

  Widget _buildNonEmptyItems(
    BuildContext context,
    List<T> data,
  ) {
    return ListView.builder(
      itemCount: data.length,
      padding: onAdded != null
          ? EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 2)
          : null,
      itemBuilder: (context, i) {
        return itemBuilder(context, i, data[i]);
      },
    );
  }

  Widget _buildEmptyItems(BuildContext context) {
    final i18n = I18n.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Empty(
          icon: emptyIcon ?? Mdi.viewList,
          text: emptyText ?? i18n.noItems,
        ),
      ],
    );
  }
}
