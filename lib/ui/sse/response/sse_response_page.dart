import 'package:flutter/material.dart';
import 'package:restler/blocs/sse/message.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/messager.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/empty.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/table_page.dart';

class SseResponsePage extends StatefulWidget {
  final List<Message> items;

  const SseResponsePage({
    Key key,
    @required this.items,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SseResponseState();
  }
}

class _SseResponseState extends State<SseResponsePage>
    with StateMixin<SseResponsePage> {
  final Messager _message = kiwi();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.items.isEmpty) {
      return Empty(
        icon: Mdi.text,
        text: i18n.noMessages,
      );
    }

    return TablePage<Message>(
      items: widget.items,
      columnWidths: {
        0: const FractionColumnWidth(0.2),
        1: const FractionColumnWidth(0.1),
        2: const FractionColumnWidth(0.2),
        3: const FractionColumnWidth(0.5),
      },
      evenColor: theme.cardColor,
      oddColor: theme.backgroundColor,
      headerBuilder: (context) {
        return [
          Text(
            i18n.time,
            style: defaultTableTextStyle,
            textAlign: TextAlign.center,
          ),
          Text(
            i18n.id,
            style: defaultTableTextStyle,
            textAlign: TextAlign.center,
          ),
          Text(
            i18n.type,
            style: defaultTableTextStyle,
            textAlign: TextAlign.center,
          ),
          Text(
            i18n.data,
            style: defaultTableTextStyle,
            textAlign: TextAlign.left,
          ),
        ];
      },
      itemBuilder: (context, index, item) {
        return [
          Text(
            i18n.timePattern(
                DateTime.fromMillisecondsSinceEpoch(item.timestamp)),
            style: defaultTableTextStyle,
            textAlign: TextAlign.center,
          ),
          Text(
            item.data.id ?? '',
            style: defaultTableTextStyle,
            textAlign: TextAlign.center,
          ),
          Text(
            item.data.event ?? '',
            style: defaultTableTextStyle,
            textAlign: TextAlign.center,
          ),
          GestureDetector(
            onTap: () async {
              if (await copyToClipboard(item.data.data)) {
                _message.show((i18n) => i18n.copiedToClipboard);
              }
            },
            child: Text(
              item.data.data ?? '',
              style: defaultTableTextStyle,
              textAlign: TextAlign.left,
            ),
          ),
        ];
      },
    );
  }
}
