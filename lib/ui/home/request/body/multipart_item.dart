import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restler/data/entities/multipart_entity.dart';
import 'package:restler/data/entities/multipart_file_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

enum MultipartItemAction { file, text, remove, duplicate, delete }

class MultipartItem extends StatefulWidget {
  final MultipartEntity item;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<MultipartItemAction> onActionSelected;
  final ValueChanged<MultipartType> onTypeChanged;
  final ValueChanged<MultipartFileEntity> onFileChanged;
  final ValueChanged<MultipartEntity> onItemChanged;

  const MultipartItem({
    Key key,
    @required this.item,
    this.onActionSelected,
    this.onEnabled,
    this.onNameChanged,
    this.onValueChanged,
    this.onTypeChanged,
    this.onFileChanged,
    this.onItemChanged,
  })  : assert(item != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MultipartItemState();
  }
}

class _MultipartItemState extends State<MultipartItem>
    with StateMixin<MultipartItem> {
  TextEditingController _nameTextController;
  TextEditingController _valueTextController;
  ValueNotifier<MultipartType> _type;
  ValueNotifier<MultipartFileEntity> _file;

  @override
  void initState() {
    _nameTextController = TextEditingController(text: widget.item.name);
    _valueTextController = TextEditingController(text: widget.item.value);

    _type = ValueNotifier(widget.item.type);
    _file = ValueNotifier(widget.item.file);

    super.initState();
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _valueTextController.dispose();

    _type.dispose();
    _file.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    suggestionsCallback: variableSuggestions,
                    showDefaultItems: false,
                  ),
                ),
              ),
              // Value.
              Expanded(
                flex: 50,
                child: ValueListenableBuilder(
                  valueListenable: _type,
                  builder: (context, type, child) {
                    if (type == MultipartType.text) {
                      return PowerfulTextField(
                        controller: _valueTextController,
                        // TODO: Suportar futuramente multiline exibindo num dialog.
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
                        suggestionsCallback: variableSuggestions,
                        showDefaultItems: false,
                      );
                    } else {
                      // Choose file...
                      return FlatButton(
                        color: Theme.of(context).indicatorColor,
                        onPressed: _onChooseFile,
                        child: ValueListenableBuilder<MultipartFileEntity>(
                          valueListenable: _file,
                          builder: (context, file, child) {
                            return Text(
                              file?.path?.isNotEmpty == true
                                  ? file.path
                                  : i18n.choose,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          trailing: ValueListenableBuilder(
            valueListenable: _type,
            builder: (context, type, child) {
              // Menu.
              return DotMenuButton<MultipartItemAction>(
                items: _obtainActionsByType(type),
                itemBuilder: (context, index, action) {
                  switch (action) {
                    // Text.
                    case MultipartItemAction.text:
                      return ListTile(
                        leading: const Icon(Mdi.text),
                        title: Text(i18n.text),
                      );
                    // File.
                    case MultipartItemAction.file:
                      return ListTile(
                        leading: const Icon(Mdi.file),
                        title: Text(i18n.file),
                      );
                    case MultipartItemAction.remove:
                      return ListTile(
                        leading: const Icon(Icons.clear),
                        title: Text(i18n.clear),
                      );
                    // Duplicate.
                    case MultipartItemAction.duplicate:
                      return ListTile(
                        leading: const Icon(Icons.content_copy),
                        title: Text(i18n.duplicate),
                      );
                    // Delete.
                    case MultipartItemAction.delete:
                      return ListTile(
                        leading: const Icon(Icons.delete),
                        title: Text(i18n.delete),
                      );
                    default:
                      return null;
                  }
                },
                onSelected: _onActionSelected,
              );
            },
          ),
        ),
      ),
    );
  }

  List<MultipartItemAction> _obtainActionsByType(MultipartType type) {
    return [
      if (type == MultipartType.file) ...[
        MultipartItemAction.remove,
        MultipartItemAction.text,
      ] else
        MultipartItemAction.file,
      MultipartItemAction.duplicate,
      MultipartItemAction.delete,
    ];
  }

  void _onActionSelected(MultipartItemAction action) {
    if (action == MultipartItemAction.file) {
      _type.value = MultipartType.file;
      widget.onTypeChanged?.call(MultipartType.file);
      widget.onItemChanged
          ?.call(widget.item.copyWith(type: MultipartType.file));
    } else if (action == MultipartItemAction.text) {
      _type.value = MultipartType.text;
      widget.onTypeChanged?.call(MultipartType.file);
      widget.onItemChanged
          ?.call(widget.item.copyWith(type: MultipartType.text));
    } else if (action == MultipartItemAction.remove) {
      _file.value = MultipartFileEntity.empty;
      widget.onFileChanged?.call(MultipartFileEntity.empty);
      widget.onItemChanged
          ?.call(widget.item.copyWith(file: MultipartFileEntity.empty));
    }

    widget.onActionSelected?.call(action);
  }

  Future<void> _onChooseFile() async {
    try {
      final res = await FilePicker.platform.pickFiles();

      if (res != null && res.files.isNotEmpty) {
        final path = res.paths[0];
        final name = path.split('/').last;
        final file = MultipartFileEntity(path: path, name: name);
        _file.value = file;
        widget.onFileChanged?.call(file);
        widget.onItemChanged?.call(widget.item.copyWith(file: file));
      }
    } on Exception catch (e) {
      print('Error while picking the file: $e');
    }
  }
}
