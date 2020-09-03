import 'package:flutter/material.dart';
import 'package:restler/ui/widgets/circular_progress_button.dart';

class SendButton extends StatelessWidget {
  final void Function(bool sending) onStateChanged;
  final bool sending;

  const SendButton({
    Key key,
    this.onStateChanged,
    this.sending = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sending) {
      return CircularProgressButton(
        onPressed: () {
          onStateChanged?.call(false);
        },
        icon: Icons.cancel,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.send),
        onPressed: () {
          onStateChanged?.call(true);
        },
      );
    }
  }
}
