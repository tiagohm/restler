import 'package:flutter/material.dart';

class ContextMenuButton<T> extends StatelessWidget {
  final T initialValue;
  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final PopupMenuItemSelected<T> onChanged;
  final Offset offset;

  const ContextMenuButton({
    Key key,
    this.initialValue,
    @required this.items,
    @required this.itemBuilder,
    this.onChanged,
    this.offset,
  })  : assert(itemBuilder != null),
        assert(items != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      // width: 72,
      child: PopupMenuButton<T>(
        offset: offset ?? Offset.zero,
        initialValue: initialValue,
        itemBuilder: (context) {
          return [
            for (var i = 0; i < items.length; i++)
              PopupMenuItem(
                value: items[i],
                child: itemBuilder(context, i, items[i]),
              ),
          ];
        },
        onSelected: onChanged,
        child: itemBuilder(context, -1, initialValue),
      ),
    );
  }
}
