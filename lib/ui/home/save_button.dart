import 'package:flutter/material.dart';
import 'package:restler/mdi.dart';

class SaveButton extends StatelessWidget {
  final bool saved;
  final VoidCallback onPressed;

  const SaveButton({
    Key key,
    this.saved = false,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        IconButton(
          icon: const Icon(Mdi.save),
          onPressed: onPressed,
        ),
        Positioned(
          right: 10,
          bottom: 13,
          child: Visibility(
            visible: !saved,
            child: const Icon(
              Mdi.circle,
              color: Colors.blue,
              size: 10,
            ),
          ),
        ),
      ],
    );
  }
}
