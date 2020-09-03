import 'package:flutter/material.dart';

class CircularProgressButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Widget child;

  const CircularProgressButton({
    Key key,
    @required this.onPressed,
    this.icon,
    this.child,
  })  : assert(icon != null || child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Positioned(
          child: CircularProgressIndicator(),
        ),
        Positioned(
          child: GestureDetector(
            onTap: onPressed,
            child: child ??
                AbsorbPointer(
                  child: IconButton(
                    icon: Icon(icon),
                    onPressed: () {},
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
