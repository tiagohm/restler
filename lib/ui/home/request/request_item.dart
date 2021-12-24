import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restler/data/entities/item_entity.dart';
import 'package:restler/i18n.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';
import 'package:restler/ui/widgets/item_menu_button.dart';
import 'package:restler/ui/widgets/multiline_text_dialog.dart';
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
  final List<String> menuItems;

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
    this.menuItems,
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
      padding: const EdgeInsets.only(top: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        // horizontalTitleGap: 4,
        dense: true,
        // Enable.
        leading: Checkbox(
          value: widget.item.enabled,
          onChanged: (checked) {
            widget.onEnabled?.call(checked);
            widget.onItemChanged?.call(widget.item.copyWith(enabled: checked));
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Name.
            Expanded(
              flex: 50,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: widget.menuItems != null && widget.menuItems.isNotEmpty
                    ? ItemMenuButton(
                        initialValue: widget.item.name,
                        items: widget.menuItems,
                        onChanged: (value) {
                          widget.onNameChanged?.call(value);
                          widget.onItemChanged
                              ?.call(widget.item.copyWith(name: value));
                        },
                      )
                    : PowerfulTextField(
                        controller: _nameTextController,
                        style: defaultInputTextStyle,
                        hintText: i18n.name.toLowerCase(),
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
                hintText: i18n.value.toLowerCase(),
                onChanged: (text) {
                  widget.onValueChanged?.call(text);
                  widget.onItemChanged?.call(widget.item.copyWith(value: text));
                },
                suggestionsCallback: widget.valueSuggestions,
                showDefaultItems: false,
                maxLines: null,
              ),
            ),
          ],
        ),
        // Menu.
        trailing: DotMenuButton<String>(
          items: ['dup', 'edit', null, 'del'],
          itemBuilder: (context, index, action) {
            switch (action) {
              // Duplicate.
              case 'dup':
                return ListTile(
                  leading: const Icon(Icons.content_copy),
                  title: Text(i18n.duplicate),
                );
              // Delete.
              case 'del':
                return ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text(i18n.delete),
                );
              // Edit.
              case 'edit':
                return ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(i18n.edit),
                );
              default:
                return null;
            }
          },
          onSelected: (value) async {
            switch (value) {
              case 'dup':
                return widget.onActionSelected(RequestItemAction.duplicate);
              case 'del':
                return widget.onActionSelected(RequestItemAction.delete);
              case 'edit':
                final res = await MultilineTextDialog.show(
                  context,
                  i18n.value,
                  _valueTextController.text,
                  suggestionsCallback: widget.valueSuggestions,
                );

                if (res != null && !res.cancelled) {
                  final text = res.data;
                  _valueTextController.text = text;
                  widget.onValueChanged?.call(text);
                  widget.onItemChanged?.call(widget.item.copyWith(value: text));
                }
                break;
            }
          },
        ),
      ),
    );
  }
}
