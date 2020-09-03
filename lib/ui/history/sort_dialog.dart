import 'package:flutter/material.dart';
import 'package:restler/blocs/history/bloc.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class SortDialog extends StatefulWidget {
  final Sort sort;

  const SortDialog({
    Key key,
    this.sort,
  }) : super(key: key);

  static Future<DialogResult<Sort>> show(
    BuildContext context,
    Sort sort,
  ) async {
    return showDialog<DialogResult<Sort>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SortDialog(sort: sort),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _SortDialogState();
  }
}

class _SortDialogState extends State<SortDialog> with StateMixin<SortDialog> {
  ValueNotifier<SortType> _sortType;
  ValueNotifier<bool> _sortOrder;

  @override
  void initState() {
    _sortType = ValueNotifier(widget.sort.type);
    _sortOrder = ValueNotifier(widget.sort.ascending);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<Sort>(
      doneText: i18n.sort,
      onDone: _onSort,
      title: i18n.sort,
      bodyBuilder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Sort type.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Label.
                    Text('${i18n.sortBy}: '),
                    // Dropdown.
                    ValueListenableBuilder<SortType>(
                      valueListenable: _sortType,
                      builder: (context, type, child) {
                        return DropdownButton<SortType>(
                          value: type,
                          items: [
                            for (final item in SortType.values)
                              DropdownMenuItem(
                                value: item,
                                child: Text(_obtainSortTypeName(item)),
                              ),
                          ],
                          onChanged: (type) {
                            _sortType.value = type;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Ascending order.
              ValueListenableBuilder<bool>(
                valueListenable: _sortOrder,
                builder: (context, order, child) {
                  return Row(
                    children: <Widget>[
                      Checkbox(
                        value: order,
                        onChanged: (enabled) {
                          _sortOrder.value = enabled;
                        },
                      ),
                      Text(i18n.ascendingOrder),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _obtainSortTypeName(SortType type) {
    switch (type) {
      case SortType.date:
        return i18n.date;
      case SortType.url:
        return i18n.url;
      case SortType.method:
        return i18n.method;
      case SortType.status:
        return i18n.status;
      case SortType.duration:
        return i18n.duration;
      case SortType.size:
        return i18n.size;
      default:
        return null;
    }
  }

  Future<Sort> _onSort() async {
    return Sort(
      type: _sortType.value,
      ascending: _sortOrder.value,
    );
  }
}
