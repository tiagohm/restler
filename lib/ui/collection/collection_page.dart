import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restler/blocs/collection/bloc.dart';
import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/messager.dart';
import 'package:restler/ui/collection/call_card.dart';
import 'package:restler/ui/collection/copy_call_dialog.dart';
import 'package:restler/ui/collection/export_dialog.dart';
import 'package:restler/ui/collection/folder_card.dart';
import 'package:restler/ui/collection/import_dialog.dart';
import 'package:restler/ui/collection/move_call_dialog.dart';
import 'package:restler/ui/collection/move_folder_dialog.dart';
import 'package:restler/ui/widgets/default_app_bar.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/input_text_dialog.dart';
import 'package:restler/ui/widgets/list_page.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

enum CollectionPageAction { search, import, export }

class CollectionPage extends StatefulWidget {
  const CollectionPage({
    Key key,
  }) : super(key: key);

  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage>
    with StateMixin<CollectionPage> {
  final Messager _messager = kiwi();
  final _bloc = CollectionBloc();
  final _searchTextController = TextEditingController();

  @override
  void initState() {
    _messager.registerOnState(this);
    _bloc.add(CollectionFetched());
    super.initState();
  }

  @override
  void dispose() {
    _messager.unregisterOnState(this);
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        // Back.
        onBack: () {
          // Já estamos na pasta-raiz.
          if (_bloc.state.folder?.uid == null) {
            return true;
          } else {
            _bloc.add(Backwarded());
            return false;
          }
        },
        // Title.
        title: BlocBuilder<CollectionBloc, CollectionState>(
          cubit: _bloc,
          buildWhen: (a, b) => a.search != b.search,
          builder: (context, state) {
            // Search.
            if (state.search) {
              return PowerfulTextField(
                controller: _searchTextController,
                onChanged: (text) {
                  _bloc.add(SearchTextChanged(text));
                },
                hintText: i18n.search,
              );
            }
            // Title.
            else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title.
                  Text(i18n.collection),
                  // Counter.
                  BlocBuilder<CollectionBloc, CollectionState>(
                    cubit: _bloc,
                    buildWhen: (a, b) => a.data.length != b.data.length,
                    builder: (context, state) {
                      return Text(
                        i18n.itemCount(state.data.length),
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
        items: CollectionPageAction.values,
        itemBuilder: (context, action) {
          if (action == CollectionPageAction.search) {
            return const Icon(Icons.search);
          } else if (action == CollectionPageAction.import) {
            return const Icon(Mdi.import);
          } else {
            return const Icon(Mdi.export);
          }
        },
        onItemSelected: (item) async {
          // Search.
          if (item == CollectionPageAction.search) {
            _bloc.add(SearchToggled());
          }
          // Import.
          else if (item == CollectionPageAction.import) {
            final res = await ImportDialog.show(context);

            if (!res.cancelled && res.data != null) {
              _bloc.add(CollectionImported(res.data));
            }
          }
          // Export.
          else if (item == CollectionPageAction.export) {
            final res = await ExportDialog.show(context);

            if (!res.cancelled && res.data != null) {
              if (await handlePermission(Permission.storage)) {
                final path = await FilePicker.platform.getDirectoryPath();

                if (path != null) {
                  _bloc.add(CollectionExported(res.data, path));
                }
              }
            }
          }
        },
      ),
      // List.
      body: BlocBuilder<CollectionBloc, CollectionState>(
        cubit: _bloc,
        buildWhen: (a, b) => a.data != b.data,
        builder: (context, state) {
          return ListPage(
            emptyIcon: Icons.folder,
            addIcon: Mdi.folderPlus,
            items: state.data,
            onAdded: () async {
              // Exibe uma janela de diálogo para o usuário digital o nome da pasta.
              final res = await InputTextDialog.show(
                context,
                null,
                i18n.name,
                i18n.newFolder,
              );

              if (!res.cancelled) {
                _bloc.add(FolderCreated(res.data));
              }
            },
            itemBuilder: (context, i, item) {
              // Card.
              if (item is FolderEntity) {
                return FolderCard(
                  folder: item,
                  key: Key(item.uid),
                  onFavorited: (favorited) {
                    _bloc.add(FolderFavorited(item));
                  },
                  onActionSelected: (action) async {
                    // Edit.
                    if (action == FolderCardAction.edit) {
                      // Exibe uma janela de diálogo para o usuário digitar o nome da pasta.
                      final res = await InputTextDialog.show(
                        context,
                        item.name,
                        i18n.name,
                        i18n.editFolder,
                      );

                      if (!res.cancelled) {
                        _bloc.add(FolderEdited(item.copyWith(name: res.data)));
                      }
                    }
                    // Move.
                    else if (action == FolderCardAction.move) {
                      final res = await MoveFolderDialog.show(context, item);

                      if (!res.cancelled && res.data != null) {
                        _bloc.add(FolderMoved(item, res.data[0], res.data[1]));
                      }
                    }
                    // Delete.
                    else if (action == FolderCardAction.delete) {
                      _messager.show(
                        (i18n) => i18n.deleteFolderConfirmationMessage,
                        actionText: i18n.yes,
                        onYes: () => _bloc.add(FolderDeleted(item)),
                      );
                    }
                    // Import.
                    else if (action == FolderCardAction.import) {
                      final res = await ImportDialog.show(context);

                      if (!res.cancelled && res.data != null) {
                        _bloc.add(CollectionImported(res.data, item));
                      }
                    }
                  },
                  onTap: () {
                    _bloc.add(Forwarded(item));
                  },
                );
              } else if (item is CallEntity) {
                return CallCard(
                  call: item,
                  key: Key(item.uid),
                  onTap: () {
                    Navigator.pop(context, item);
                  },
                  onFavorited: (favorited) {
                    _bloc.add(CallFavorited(item));
                  },
                  onActionSelected: (action) async {
                    // Edit.
                    if (action == CallCardAction.edit) {
                      // Exibe a janela de diálogo para digitar o nome da chamada.
                      final res = await InputTextDialog.show(
                        context,
                        item.name,
                        i18n.name,
                        i18n.editCall,
                      );

                      if (!res.cancelled) {
                        _bloc.add(CallEdited(item.copyWith(name: res.data)));
                      }
                    }
                    // Move.
                    else if (action == CallCardAction.move) {
                      final res = await MoveCallDialog.show(
                        context,
                        item,
                      );

                      if (!res.cancelled && res.data != null) {
                        _bloc.add(CallMoved(item, res.data[0], res.data[1]));
                      }
                    }
                    // Duplicate.
                    else if (action == CallCardAction.duplicate) {
                      _bloc.add(CallDuplicated(item));
                    }
                    // Copy.
                    else if (action == CallCardAction.copy) {
                      final res = await CopyCallDialog.show(
                        context,
                        item,
                      );

                      if (!res.cancelled && res.data != null) {
                        _bloc.add(CallCopied(
                            item, res.data[0], res.data[1], res.data[2]));
                      }
                    }
                    // Delete.
                    else if (action == CallCardAction.delete) {
                      _messager.show(
                        (i18n) => i18n.deleteCallConfirmationMessage,
                        actionText: i18n.yes,
                        onYes: () => _bloc.add(CallDeleted(item)),
                      );
                    }
                  },
                );
              } else {
                return null;
              }
            },
          );
        },
      ),
    );
  }
}
