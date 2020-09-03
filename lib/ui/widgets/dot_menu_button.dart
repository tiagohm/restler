import 'package:flutter/material.dart';

class DotMenuButton<T> extends StatelessWidget {
  /// Use null values for create dividers.
  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final ValueChanged<T> onSelected;
  final Icon icon;

  const DotMenuButton({
    Key key,
    @required this.items,
    @required this.itemBuilder,
    this.onSelected,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      icon: icon,
      itemBuilder: (context) {
        return [
          for (var i = 0; i < items.length; i++)
            if (items[i] == null)
              const PopupMenuDivider(
                height: 10,
              )
            else
              PopupMenuItem(
                value: items[i],
                child: itemBuilder(context, i, items[i]),
              ),
        ];
      },
      onSelected: onSelected,
    );
  }
}
