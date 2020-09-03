import 'package:flutter/material.dart';
import 'package:restler/blocs/websocket/message.dart';
import 'package:restler/i18n.dart';
import 'package:restler/ui/constants.dart';

class ResponseItem extends StatelessWidget {
  final Message message;
  final VoidCallback onTap;

  const ResponseItem({
    Key key,
    @required this.message,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = I18n.of(context).timePattern(
      DateTime.fromMillisecondsSinceEpoch(message.timestamp),
    );

    return GestureDetector(
      onTap: onTap,
      child: Material(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
          child: RichText(
            text: TextSpan(
              children: [
                // Date.
                TextSpan(
                  text: '$date: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: message.sent ? Colors.blue : Colors.green,
                  ),
                ),
                // Data.
                TextSpan(
                  text: message.data,
                  style: defaultInputTextStyle.copyWith(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
