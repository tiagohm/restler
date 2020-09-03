import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restler/constants.dart';
import 'package:restler/data/entities/header_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/ui/home/request/request_item.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

class HeaderItem extends StatelessWidget {
  final HeaderEntity item;
  final ValueChanged<RequestItemAction> onActionSelected;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<HeaderEntity> onItemChanged;

  const HeaderItem({
    @required this.item,
    this.onActionSelected,
    this.onEnabled,
    this.onNameChanged,
    this.onValueChanged,
    this.onItemChanged,
  });

  Future<List<AutocompleteItem>> _nameSuggestions(
    String text,
    int cursorPosition,
  ) async {
    text = text.toLowerCase();

    final res = <AutocompleteItem>[];

    (await variableSuggestions(text, cursorPosition)).forEach(res.add);

    for (final name in headerNames) {
      if (name.contains(text)) {
        res.add(ValueAutocompleteItem(name, 'HEADER'));
      }
    }

    return res;
  }

  Future<List<AutocompleteItem>> _valueSuggestions(
    String text,
    int cursorPosition,
  ) async {
    text = text.toLowerCase();

    final res = <AutocompleteItem>[];

    (await variableSuggestions(text, cursorPosition)).forEach(res.add);

    for (final name in headerValues) {
      if (name.contains(text)) {
        res.add(ValueAutocompleteItem(name, 'HEADER'));
      }
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return RequestItem<HeaderEntity>(
      key: Key(item.uid),
      item: item,
      onActionSelected: onActionSelected,
      onEnabled: onEnabled,
      onNameChanged: onNameChanged,
      onValueChanged: onValueChanged,
      onItemChanged: onItemChanged,
      nameSuggestions: _nameSuggestions,
      valueSuggestions: _valueSuggestions,
    );
  }
}
