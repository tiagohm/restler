import 'dart:async';

import 'package:flutter/material.dart';
import 'package:restler/i18n.dart';
import 'package:restler/ui/widgets/action_button.dart';
import 'package:restler/ui/widgets/dialog_result.dart';

class DataDialog<T> extends StatelessWidget {
  final String title;
  final bool showCancel;
  final bool showDone;
  final String cancelText;
  final String doneText;
  final FutureOr<T> Function() onCancel;
  final FutureOr<T> Function() onDone;
  final Widget Function(BuildContext context) bodyBuilder;
  final Widget leading;
  final Widget trailing;

  const DataDialog({
    Key key,
    @required this.title,
    this.showCancel = true,
    this.showDone = true,
    this.cancelText,
    this.doneText,
    this.onCancel,
    this.onDone,
    this.bodyBuilder,
    this.leading,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

    return AlertDialog(
      title: Row(
        children: <Widget>[
          // Icon.
          if (leading != null)
            Flexible(
              flex: 25,
              child: leading,
            ),
          // Title.
          Expanded(
            flex: 50,
            child: Text(title),
          ),
          // Icon.
          if (trailing != null)
            Flexible(
              flex: 25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  trailing,
                ],
              ),
            ),
        ],
      ),
      content: bodyBuilder(context),
      actions: [
        // Cancel.
        if (showCancel)
          ActionButton(
            text: cancelText?.toUpperCase() ?? i18n.cancel.toUpperCase(),
            onPressed: () async {
              Navigator.pop(
                context,
                DialogResult(cancelled: true, data: await onCancel?.call()),
              );
            },
          ),
        // Done.
        if (showDone)
          ActionButton(
            text: doneText?.toUpperCase() ?? i18n.ok.toUpperCase(),
            onPressed: () async {
              final res = await onDone?.call();

              if (res != null) {
                Navigator.pop(context, DialogResult.ok(res));
              }
            },
          ),
      ],
    );
  }
}
