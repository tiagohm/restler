import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String text;
  final Color color;

  const Label({
    Key key,
    this.text,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(2),
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).cardColor,
          ),
        ),
      ),
    );
  }
}
