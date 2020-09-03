import 'package:flutter/material.dart';

class Empty extends StatelessWidget {
  final IconData icon;
  final String text;

  const Empty({
    Key key,
    @required this.icon,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon.
        Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(
            icon,
            size: 96,
          ),
        ),
        // Text.
        if (text != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
            ),
          ),
      ],
    );
  }
}
