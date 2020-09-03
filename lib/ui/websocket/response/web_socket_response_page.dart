import 'package:flutter/material.dart';
import 'package:restler/blocs/websocket/message.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/messager.dart';
import 'package:restler/ui/websocket/response/response_item.dart';
import 'package:restler/ui/widgets/empty.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class WebSocketResponsePage extends StatefulWidget {
  final List<Message> items;

  const WebSocketResponsePage({
    Key key,
    @required this.items,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WebSocketResponseState();
  }
}

class _WebSocketResponseState extends State<WebSocketResponsePage>
    with StateMixin<WebSocketResponsePage> {
  final _scrollCrontroller = ScrollController();
  final Messager _message = kiwi();

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Empty(
        icon: Mdi.text,
        text: i18n.noMessages,
      );
    }

    return Scrollbar(
      child: ListView.builder(
        controller: _scrollCrontroller,
        shrinkWrap: true,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          // Item.
          return ResponseItem(
            message: widget.items[index],
            onTap: () async {
              if (await copyToClipboard(widget.items[index].data)) {
                _message.show((i18n) => i18n.copiedToClipboard);
              }
            },
          );
        },
      ),
    );
  }
}
