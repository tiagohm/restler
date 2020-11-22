import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/dns/bloc.dart';
import 'package:restler/data/entities/dns_entity.dart';
import 'package:restler/inject.dart';
import 'package:restler/messager.dart';
import 'package:restler/ui/dns/create_edit_dns_dialog.dart';
import 'package:restler/ui/dns/dns_card.dart';
import 'package:restler/ui/widgets/default_app_bar.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/list_page.dart';
import 'package:restler/ui/widgets/move_to_workspace_dialog.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

enum DnsPageAction { search, clear }

class DnsPage extends StatefulWidget {
  const DnsPage({
    Key key,
  }) : super(key: key);

  @override
  _DnsPageState createState() => _DnsPageState();
}

class _DnsPageState extends State<DnsPage> with StateMixin<DnsPage> {
  final Messager _messager = kiwi();
  final _bloc = DnsBloc();
  final _searchTextController = TextEditingController();

  @override
  void initState() {
    _messager.registerOnState(this);
    _bloc.add(DnsFetched());
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
        title: BlocBuilder<DnsBloc, DnsState>(
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
                underlined: true,
              );
            }
            // Title.
            else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title.
                  Text(i18n.dns),
                  // Counter.
                  BlocBuilder<DnsBloc, DnsState>(
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
        items: DnsPageAction.values,
        itemBuilder: (context, action) {
          if (action == DnsPageAction.search) {
            return const Icon(Icons.search);
          } else {
            return const Icon(Icons.clear_all);
          }
        },
        onItemSelected: (item) async {
          // Search.
          if (item == DnsPageAction.search) {
            _bloc.add(SearchToggled());
          }
          // Clear.
          else {
            _messager.show(
              (i18n) => i18n.clearDnsConfirmationMessage,
              actionText: i18n.yes,
              onYes: () => _bloc.add(DnsCleared()),
            );
          }
        },
      ),
      // List.
      body: BlocBuilder<DnsBloc, DnsState>(
        cubit: _bloc,
        buildWhen: (a, b) => a.data != b.data,
        builder: (context, state) {
          return ListPage<DnsEntity>(
            emptyIcon: Icons.dns,
            items: state.data,
            itemBuilder: (context, i, item) {
              // Card.
              return DnsCard(
                dns: item,
                key: Key(item.uid),
                // Enabled.
                onEnabled: (enabled) {
                  _bloc.add(
                    DnsEdited(item.copyWith(enabled: !item.enabled)),
                  );
                },
                onActionSelected: (action) async {
                  // Edit.
                  if (action == DnsCardAction.edit) {
                    final res = await CreateEditDnsDialog.show(context, item);

                    if (res != null && !res.cancelled && res.data != null) {
                      _bloc.add(DnsEdited(res.data));
                    }
                  }
                  // Duplicated.
                  else if (action == DnsCardAction.duplicate) {
                    _bloc.add(DnsDuplicated(item));
                  }
                  // Move.
                  else if (action == DnsCardAction.move) {
                    final res = await MoveToWorkspaceDialog.show(
                      context,
                      item.workspace,
                      i18n.moveDns,
                    );

                    if (res != null && !res.cancelled && res.data != null) {
                      _bloc.add(DnsMoved(item, res.data));
                    }
                  }
                  // Copy.
                  else if (action == DnsCardAction.copy) {
                    final res = await MoveToWorkspaceDialog.show(
                      context,
                      item.workspace,
                      i18n.copyDns,
                    );

                    if (res != null && !res.cancelled && res.data != null) {
                      _bloc.add(DnsCopied(item, res.data));
                    }
                  }
                  // Delete.
                  else if (action == DnsCardAction.delete) {
                    _messager.show(
                      (i18n) => i18n.deleteDnsConfirmationMessage,
                      actionText: i18n.yes,
                      onYes: () => _bloc.add(DnsDeleted(item)),
                    );
                  }
                },
              );
            },
            // Add.
            onAdded: () async {
              final res = await CreateEditDnsDialog.show(context, null);

              if (res != null && !res.cancelled && res.data != null) {
                _bloc.add(DnsCreated(res.data));
              }
            },
          );
        },
      ),
    );
  }
}
