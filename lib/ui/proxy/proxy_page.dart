import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/proxy/bloc.dart';
import 'package:restler/data/entities/proxy_entity.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/messager.dart';
import 'package:restler/ui/proxy/create_edit_proxy_dialog.dart';
import 'package:restler/ui/proxy/proxy_card.dart';
import 'package:restler/ui/widgets/default_app_bar.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/list_page.dart';
import 'package:restler/ui/widgets/move_to_workspace_dialog.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

enum ProxyPageAction { search, clear }

class ProxyPage extends StatefulWidget {
  const ProxyPage({
    Key key,
  }) : super(key: key);

  @override
  _ProxyPageState createState() => _ProxyPageState();
}

class _ProxyPageState extends State<ProxyPage> with StateMixin<ProxyPage> {
  final Messager _messager = kiwi();
  final _bloc = ProxyBloc();
  final _searchTextController = TextEditingController();

  @override
  void initState() {
    _messager.registerOnState(this);
    _bloc.add(ProxyFetched());
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
        title: BlocBuilder<ProxyBloc, ProxyState>(
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
                  Text(i18n.proxy),
                  // Counter.
                  BlocBuilder<ProxyBloc, ProxyState>(
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
        items: ProxyPageAction.values,
        itemBuilder: (context, action) {
          if (action == ProxyPageAction.search) {
            return const Icon(Icons.search);
          } else {
            return const Icon(Icons.clear_all);
          }
        },
        onItemSelected: (item) async {
          // Search.
          if (item == ProxyPageAction.search) {
            _bloc.add(SearchToggled());
          }
          // Clear.
          else {
            _messager.show(
              (i18n) => i18n.clearProxyConfirmationMessage,
              actionText: i18n.yes,
              onYes: () => _bloc.add(ProxyCleared()),
            );
          }
        },
      ),
      // List.
      body: BlocBuilder<ProxyBloc, ProxyState>(
        cubit: _bloc,
        buildWhen: (a, b) => a.data != b.data,
        builder: (context, state) {
          return ListPage<ProxyEntity>(
            emptyIcon: Mdi.serverNetwork,
            items: state.data,
            itemBuilder: (context, i, item) {
              // Card.
              return ProxyCard(
                proxy: item,
                key: Key(item.uid),
                // Enabled.
                onEnabled: (enabled) {
                  _bloc.add(
                    ProxyEdited(item.copyWith(enabled: !item.enabled)),
                  );
                },
                onActionSelected: (action) async {
                  // Edit.
                  if (action == ProxyCardAction.edit) {
                    final res = await CreateEditProxyDialog.show(context, item);

                    if (!res.cancelled && res.data != null) {
                      _bloc.add(ProxyEdited(res.data));
                    }
                  }
                  // Duplicated.
                  else if (action == ProxyCardAction.duplicate) {
                    _bloc.add(ProxyDuplicated(item));
                  }
                  // Move.
                  else if (action == ProxyCardAction.move) {
                    final res = await MoveToWorkspaceDialog.show(
                      context,
                      item.workspace,
                      i18n.moveProxy,
                    );

                    if (!res.cancelled && res.data != null) {
                      _bloc.add(ProxyMoved(item, res.data));
                    }
                  }
                  // Copy.
                  else if (action == ProxyCardAction.copy) {
                    final res = await MoveToWorkspaceDialog.show(
                      context,
                      item.workspace,
                      i18n.copyProxy,
                    );

                    if (!res.cancelled && res.data != null) {
                      _bloc.add(ProxyCopied(item, res.data));
                    }
                  }
                  // Delete.
                  else if (action == ProxyCardAction.delete) {
                    _messager.show(
                      (i18n) => i18n.deleteProxyConfirmationMessage,
                      actionText: i18n.yes,
                      onYes: () => _bloc.add(ProxyDeleted(item)),
                    );
                  }
                },
              );
            },
            // Add.
            onAdded: () async {
              final res = await CreateEditProxyDialog.show(context, null);

              if (!res.cancelled && res.data != null) {
                _bloc.add(ProxyCreated(res.data));
              }
            },
          );
        },
      ),
    );
  }
}
