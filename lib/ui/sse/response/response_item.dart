import 'package:flutter/material.dart';
import 'package:restler/blocs/sse/message.dart';
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
                  text: '$date',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
                // Type.
                if (message.data.event != null)
                  TextSpan(
                    text: '${message.data.event} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                // Type.
                if (message.data.id != null)
                  TextSpan(
                    text: '${message.data.id} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                // Data.
                TextSpan(
                  text: message.data.data ?? '',
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
