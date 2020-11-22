import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/cookie/bloc.dart';
import 'package:restler/data/entities/cookie_entity.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/messager.dart';
import 'package:restler/ui/cookie/cookie_card.dart';
import 'package:restler/ui/cookie/create_edit_cookie_dialog.dart';
import 'package:restler/ui/widgets/default_app_bar.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/list_page.dart';
import 'package:restler/ui/widgets/move_to_workspace_dialog.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

enum CookiePageAction { search, clear }

class CookiePage extends StatefulWidget {
  const CookiePage({
    Key key,
  }) : super(key: key);

  @override
  _CookiePageState createState() => _CookiePageState();
}

class _CookiePageState extends State<CookiePage> with StateMixin<CookiePage> {
  final Messager _messager = kiwi();
  final _bloc = CookieBloc();
  final _searchTextController = TextEditingController();

  @override
  void initState() {
    _messager.registerOnState(this);
    _bloc.add(CookieFetched());
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
        onBack: () => true,
        // Title.
        title: BlocBuilder<CookieBloc, CookieState>(
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
                  Text(i18n.cookie),
                  // Counter.
                  BlocBuilder<CookieBloc, CookieState>(
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
        items: CookiePageAction.values,
        itemBuilder: (context, action) {
          if (action == CookiePageAction.search) {
            return const Icon(Icons.search);
          } else {
            return const Icon(Icons.clear_all);
          }
        },
        onItemSelected: (item) async {
          // Search.
          if (item == CookiePageAction.search) {
            _bloc.add(SearchToggled());
          }
          // Clear.
          else {
            _messager.show(
              (i18n) => i18n.clearCookieConfirmationMessage,
              actionText: i18n.yes,
              onYes: () => _bloc.add(CookieCleared()),
            );
          }
        },
      ),
      // List.
      body: BlocBuilder<CookieBloc, CookieState>(
        cubit: _bloc,
        buildWhen: (a, b) => a.data != b.data,
        builder: (context, state) {
          return ListPage<CookieEntity>(
            emptyIcon: Mdi.cookie,
            items: state.data,
            itemBuilder: (context, i, item) {
              // Card.
              return CookieCard(
                cookie: item,
                key: Key(item.uid),
                // Enabled.
                onEnabled: (enabled) {
                  _bloc.add(CookieEdited(item.copyWith(enabled: enabled)));
                },
                onActionSelected: (action) async {
                  // Edit.
                  if (action == CookieCardAction.edit) {
                    final res =
                        await CreateEditCookieDialog.show(context, item);

                    if (res != null && !res.cancelled && res.data != null) {
                      _bloc.add(CookieEdited(res.data));
                    }
                  }
                  // Duplicated.
                  else if (action == CookieCardAction.duplicate) {
                    _bloc.add(CookieDuplicated(item));
                  }
                  // Move.
                  else if (action == CookieCardAction.move) {
                    final res = await MoveToWorkspaceDialog.show(
                      context,
                      item.workspace,
                      i18n.moveCookie,
                    );

                    if (res != null && !res.cancelled && res.data != null) {
                      _bloc.add(CookieMoved(item, res.data));
                    }
                  }
                  // Copy.
                  else if (action == CookieCardAction.copy) {
                    final res = await MoveToWorkspaceDialog.show(
                      context,
                      item.workspace,
                      i18n.copyCookie,
                    );

                    if (res != null && !res.cancelled && res.data != null) {
                      _bloc.add(CookieCopied(item, res.data));
                    }
                  }
                  // Delete.
                  else if (action == CookieCardAction.delete) {
                    _messager.show(
                      (i18n) => i18n.deleteCookieConfirmationMessage,
                      actionText: i18n.yes,
                      onYes: () => _bloc.add(CookieDeleted(item)),
                    );
                  }
                },
              );
            },
            // Add.
            onAdded: () async {
              final res = await CreateEditCookieDialog.show(context, null);

              if (res != null && !res.cancelled && res.data != null) {
                _bloc.add(CookieCreated(res.data));
              }
            },
          );
        },
      ),
    );
  }
}
