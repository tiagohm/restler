import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restler/data/entities/target_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/ui/home/request/request_item.dart';

class TargetItem extends StatelessWidget {
  final TargetEntity item;
  final ValueChanged<RequestItemAction> onActionSelected;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<TargetEntity> onItemChanged;

  const TargetItem({
    @required this.item,
    this.onActionSelected,
    this.onEnabled,
    this.onNameChanged,
    this.onValueChanged,
    this.onItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RequestItem<TargetEntity>(
      key: Key(item.uid),
      item: item,
      onActionSelected: onActionSelected,
      onEnabled: onEnabled,
      onNameChanged: onNameChanged,
      onValueChanged: onValueChanged,
      onItemChanged: onItemChanged,
      valueSuggestions: variableSuggestions,
      menuItems: const ['to', 'registration_id', 'condition'],
    );
  }
}
