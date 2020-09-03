import 'package:flutter/material.dart';
import 'package:restler/ui/widgets/context_menu_button.dart';

enum HomeTabAction { rename, close }

class HomeTab<T> extends StatelessWidget {
  final T initialValue;
  final List<T> items;
  final String Function(BuildContext context, int index, T item) itemBuilder;
  final void Function(HomeTabAction action, int index, T item) onActionSelected;
  final void Function(T item) onTabSelected;

  const HomeTab({
    Key key,
    @required this.initialValue,
    @required this.items,
    @required this.itemBuilder,
    this.onTabSelected,
    this.onActionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContextMenuButton(
      offset: Offset(0, MediaQuery.of(context).padding.top),
      initialValue: initialValue,
      items: items,
      itemBuilder: (context, index, item) {
        // Aba atualmente exibida.
        if (index == -1) {
          return CustomPaint(
            painter: _HomeTabPainter(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 90),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
                    child: Text(
                      itemBuilder(context, index, item),
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 12, top: 8),
                  child: Icon(Icons.arrow_drop_down),
                ),
              ],
            ),
          );
        }
        // Outras abas.
        else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Título.
              Container(
                width: 100,
                child: Text(
                  itemBuilder(context, index, item),
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  for (final action in HomeTabAction.values)
                    // Botão de Ação.
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(_obtainHomeTabActionIcon(action), size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        onActionSelected?.call(action, index, item);
                      },
                    ),
                ],
              ),
            ],
          );
        }
      },
      onChanged: (item) {
        onTabSelected?.call(item);
      },
    );
  }

  IconData _obtainHomeTabActionIcon(HomeTabAction action) {
    switch (action) {
      case HomeTabAction.rename:
        return Icons.edit;
      case HomeTabAction.close:
        return Icons.close;
      default:
        return null;
    }
  }
}

class _HomeTabPainter extends CustomPainter {
  final Color color;

  _HomeTabPainter({
    @required this.color,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()..color = color;
    final path = Path();
    const pLeft = 2.0;
    const pRight = 2.0;
    const pTop = 8.0;

    path.moveTo(-10, size.height);
    path.quadraticBezierTo(pLeft, size.height, pLeft, size.height - 10);
    path.lineTo(pLeft, 10 + pTop);
    path.quadraticBezierTo(pLeft, pTop, 10 + pLeft, pTop);
    path.lineTo(size.width - 10 - pRight, pTop);
    path.quadraticBezierTo(
        size.width - pRight, pTop, size.width - pRight, 10 + pTop);
    path.lineTo(size.width - pRight, size.height - 10);
    path.quadraticBezierTo(
        size.width, size.height, size.width + 10, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
