import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ActionButton({
    Key key,
    @required this.text,
    this.onPressed,
  })  : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      child: Text(
        text?.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).indicatorColor,
        ),
      ),
    );
  }
}
