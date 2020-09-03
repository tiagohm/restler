import 'package:flutter/material.dart';
import 'package:restler/data/entities/redirect_entity.dart';
import 'package:restler/extensions.dart';
import 'package:restler/helper.dart';
import 'package:restler/i18n.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/messager.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/empty.dart';
import 'package:restler/ui/widgets/label.dart';
import 'package:restler/ui/widgets/table_page.dart';

class ResponseRedirectPage extends StatelessWidget {
  final List<RedirectEntity> items;

  const ResponseRedirectPage({
    Key key,
    @required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);
    final theme = Theme.of(context);
    final _message = kiwi<Messager>();

    if (items.isEmpty) {
      return Empty(
        icon: Mdi.viewList,
        text: i18n.noItems,
      );
    }

    return TablePage<RedirectEntity>(
      items: items,
      columnWidths: const {
        0: FractionColumnWidth(0.25),
        1: FractionColumnWidth(0.75),
      },
      evenColor: theme.cardColor,
      oddColor: theme.backgroundColor,
      headerBuilder: (context) {
        return [
          Text(
            i18n.time,
            style: defaultInputTextStyle.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          Text(
            i18n.url,
            style: defaultInputTextStyle.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ];
      },
      itemBuilder: (context, index, item) {
        return [
          // Time.
          Text(
            '${item.time} ms',
            style: defaultInputTextStyle,
            textAlign: TextAlign.right,
          ),
          GestureDetector(
            onTap: () async {
              if (await copyToClipboard(item.location)) {
                _message.show((i18n) => i18n.copiedToClipboard);
              }
            },
            child: Row(
              children: <Widget>[
                // Code.
                Label(
                  color: item.code.statusColor,
                  text: '${item.code}',
                ),
                Container(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Location.
                      Text(
                        item.location,
                        style: defaultInputTextStyle,
                        textAlign: TextAlign.left,
                        softWrap: true,
                      ),
                      // DNS IP.
                      if (item.ip != null && item.ip.isNotEmpty)
                        Text(
                          'IP: ${item.ip}',
                          style: defaultInputTextStyle.copyWith(
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.left,
                          softWrap: true,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
}
