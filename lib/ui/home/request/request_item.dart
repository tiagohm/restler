import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restler/data/entities/item_entity.dart';
import 'package:restler/i18n.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

enum RequestItemAction { duplicate, delete }

class RequestItem<T extends ItemEntity> extends StatefulWidget {
  final T item;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<T> onItemChanged;
  final ValueChanged<RequestItemAction> onActionSelected;
  final AutocompleteItemSuggestionCallback nameSuggestions;
  final AutocompleteItemSuggestionCallback valueSuggestions;

  const RequestItem({
    Key key,
    @required this.item,
    this.onActionSelected,
    this.onEnabled,
    this.onNameChanged,
    this.onValueChanged,
    this.onItemChanged,
    this.nameSuggestions,
    this.valueSuggestions,
  })  : assert(item != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RequestItemState<T>();
  }
}

class _RequestItemState<T extends ItemEntity> extends State<RequestItem<T>> {
  TextEditingController _nameTextController;
  TextEditingController _valueTextController;

  @override
  void initState() {
    _nameTextController = TextEditingController(text: widget.item.name);
    _valueTextController = TextEditingController(text: widget.item.value);

    super.initState();
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _valueTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        child: ListTile(
          contentPadding: const EdgeInsets.all(0),
          // Enable.
          leading: Checkbox(
            value: widget.item.enabled,
            onChanged: (checked) {
              widget.onEnabled?.call(checked);
              widget.onItemChanged
                  ?.call(widget.item.copyWith(enabled: checked));
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Name.
              Expanded(
                flex: 50,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PowerfulTextField(
                    controller: _nameTextController,
                    style: defaultInputTextStyle,
                    decoration: InputDecoration(
                      labelText: i18n.name.toLowerCase(),
                    ),
                    onChanged: (text) {
                      widget.onNameChanged?.call(text);
                      widget.onItemChanged
                          ?.call(widget.item.copyWith(name: text));
                    },
                    suggestionsCallback: widget.nameSuggestions,
                    showDefaultItems: false,
                  ),
                ),
              ),
              // Value.
              Expanded(
                flex: 50,
                child: PowerfulTextField(
                  controller: _valueTextController,
                  keyboardType: TextInputType.text,
                  style: defaultInputTextStyle,
                  decoration: InputDecoration(
                    labelText: i18n.value.toLowerCase(),
                  ),
                  onChanged: (text) {
                    widget.onValueChanged?.call(text);
                    widget.onItemChanged
                        ?.call(widget.item.copyWith(value: text));
                  },
                  suggestionsCallback: widget.valueSuggestions,
                  showDefaultItems: false,
                ),
              ),
            ],
          ),
          // Menu.
          trailing: DotMenuButton<RequestItemAction>(
            items: RequestItemAction.values,
            itemBuilder: (context, index, action) {
              switch (action) {
                // Duplicate.
                case RequestItemAction.duplicate:
                  return ListTile(
                    leading: const Icon(Icons.content_copy),
                    title: Text(i18n.duplicate),
                  );
                // Delete.
                case RequestItemAction.delete:
                  return ListTile(
                    leading: const Icon(Icons.delete),
                    title: Text(i18n.delete),
                  );
                default:
                  return null;
              }
            },
            onSelected: widget.onActionSelected,
          ),
        ),
      ),
    );
  }
}
