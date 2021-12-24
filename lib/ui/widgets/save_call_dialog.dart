import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/dropdown/bloc.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/repositories/collection_repository.dart';
import 'package:restler/inject.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/folder_item.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class SaveCallDialog extends StatefulWidget {
  final String title;
  final String name;

  const SaveCallDialog({
    Key key,
    @required this.title,
    this.name,
  }) : super(key: key);

  static Future<DialogResult<List>> show(
    BuildContext context,
    String title,
    String name,
  ) async {
    return showDialog<DialogResult<List>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SaveCallDialog(
        title: title,
        name: name,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _SaveCallDialogState();
  }
}

class _SaveCallDialogState extends State<SaveCallDialog>
    with StateMixin<SaveCallDialog> {
  final _formKey = GlobalKey<FormState>();
  final _bloc = _SaveCallBloc();
  TextEditingController _nameController;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.name ?? '');
    _bloc.add(Populated());
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<List>(
      title: widget.title,
      onCancel: () => null,
      onDone: () {
        if (_formKey.currentState.validate()) {
          final name = _nameController.text;
          final folder = _bloc.state.selected;
          return [name, folder];
        } else {
          return null;
        }
      },
      bodyBuilder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 4),
          child: Form(
            key: _formKey,
            child: ListBody(
              children: [
                // Name.
                TextFormField(
                  controller: _nameController,
                  validator: textIsRequired,
                  maxLength: 32,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.edit),
                    labelText: i18n.name,
                  ),
                  style: defaultInputTextStyle,
                ),
                // Folder.
                BlocBuilder<_SaveCallBloc, DropdownState<FolderEntity>>(
                  key: const Key('dropdown-folder'),
                  cubit: _bloc,
                  builder: (context, state) {
                    return DropdownButtonFormField<FolderEntity>(
                      key: Key(state.selected?.uid),
                      decoration: InputDecoration(
                        icon: const Icon(Icons.folder),
                        labelText: i18n.folder,
                      ),
                      items: _mapFolderEntityToDropdownItem(state.data),
                      value: state.selected,
                      onChanged: (item) {
                        _bloc.add(ItemSelected(item));
                      },
                      validator: itemIsRequired,
                      style: defaultInputTextStyle,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<DropdownMenuItem<FolderEntity>> _mapFolderEntityToDropdownItem(
    List<FolderEntity> data,
  ) {
    return [
      for (final item in data)
        DropdownMenuItem<FolderEntity>(
          value: item,
          child: FolderItem(item: item),
        ),
    ];
  }
}

class _SaveCallBloc extends DropdownBloc<FolderEntity> {
  final _collectionRepository = kiwi<CollectionRepository>();

  _SaveCallBloc()
      : super(
          const DropdownState<FolderEntity>(
            data: [FolderEntity.root],
            selected: FolderEntity.root,
          ),
        );

  @override
  Stream<DropdownState<FolderEntity>> mapPopulatedToState(
    Populated event,
  ) async* {
    final data = await _collectionRepository.searchFolder(null);
    yield state.copyWith(data: [FolderEntity.root, ...data]);
  }
}
