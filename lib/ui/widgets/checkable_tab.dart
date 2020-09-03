import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';

class CheckableTab<T> extends StatelessWidget {
  final bool isCheckable;
  final bool checked;
  final ValueChanged<bool> onChecked;
  final Widget title;
  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final ValueChanged<T> onItemSelected;
  final int badgeCount;

  CheckableTab({
    Key key,
    this.isCheckable = true,
    this.checked = false,
    this.onChecked,
    @required this.title,
    this.items,
    this.itemBuilder,
    this.onItemSelected,
    this.badgeCount,
  })  : assert(isCheckable != null),
        assert(items == null || items.isEmpty || itemBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Enable.
          if (isCheckable)
            Checkbox(
              value: checked,
              onChanged: (checked) {
                onChecked?.call(checked);
              },
            ),
          // Title.
          title,
          // Badge.
          if (badgeCount != null && badgeCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Badge(
                padding: const EdgeInsets.all(4),
                badgeColor: Theme.of(context).indicatorColor,
                badgeContent: Text(
                  badgeCount.toString(),
                  style: defaultInputTextStyle.copyWith(
                    fontSize: 9,
                    color: Theme.of(context).cardColor,
                  ),
                ),
                animationType: BadgeAnimationType.scale,
                elevation: 0,
              ),
            ),
          // Menu.
          if (items != null && items.isNotEmpty)
            DotMenuButton(
              icon: const Icon(Icons.arrow_drop_down),
              items: items,
              itemBuilder: itemBuilder,
              onSelected: onItemSelected,
            ),
        ],
      ),
    );
  }
}
