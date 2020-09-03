import 'package:flutter/material.dart';

class DefaultAppBar<T, S> extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget title;
  final List<T> items;
  final List<S> moreItems;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget Function(BuildContext context, T item) moreItemBuilder;
  final ValueChanged onItemSelected;
  final bool Function() onBack;
  final PreferredSizeWidget bottom;

  const DefaultAppBar({
    Key key,
    @required this.title,
    this.items,
    this.itemBuilder,
    this.onItemSelected,
    this.moreItems,
    this.moreItemBuilder,
    this.onBack,
    this.bottom,
  })  : assert(items == null || itemBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Back button.
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (onBack?.call() == true) {
            Navigator.pop(context);
          }
        },
      ),
      // Title.
      title: title ?? Container(),
      // Actions.
      actions: [
        if (items != null)
          for (final item in items)
            IconButton(
              icon: itemBuilder?.call(context, item),
              onPressed: () => onItemSelected?.call(item),
            ),
        // if(moreItems != null)
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize?.height ?? 0));
}
