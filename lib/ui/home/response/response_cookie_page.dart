import 'package:flutter/material.dart';
import 'package:restler/data/entities/cookie_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/i18n.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/messager.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/empty.dart';
import 'package:restler/ui/widgets/table_page.dart';

class ResponseCookiePage extends StatelessWidget {
  final List<CookieEntity> items;

  const ResponseCookiePage({
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
        icon: Mdi.text,
        text: i18n.noCookiesReturned,
      );
    }

    return TablePage<CookieEntity>(
      items: items,
      columnWidths: const {
        0: FractionColumnWidth(0.5),
        1: FractionColumnWidth(0.5),
      },
      evenColor: theme.cardColor,
      oddColor: theme.backgroundColor,
      headerBuilder: (context) {
        return [
          Text(
            i18n.name,
            style: defaultTableTextStyle,
            textAlign: TextAlign.right,
          ),
          Text(
            i18n.value,
            style: defaultTableTextStyle,
            textAlign: TextAlign.left,
          ),
        ];
      },
      itemBuilder: (context, index, item) {
        return [
          GestureDetector(
            onTap: () async {
              if (await copyToClipboard(item.name)) {
                _message.show((i18n) => i18n.copiedToClipboard);
              }
            },
            child: Text(
              item.name,
              style: defaultInputTextStyle,
              textAlign: TextAlign.right,
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (await copyToClipboard(item.value)) {
                _message.show((i18n) => i18n.copiedToClipboard);
              }
            },
            child: Text(
              item.value,
              style: defaultInputTextStyle,
              textAlign: TextAlign.left,
            ),
          ),
        ];
      },
    );
  }
}
