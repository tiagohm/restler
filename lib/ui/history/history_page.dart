import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/history/bloc.dart';
import 'package:restler/data/entities/history_entity.dart';
import 'package:restler/inject.dart';
import 'package:restler/messager.dart';
import 'package:restler/ui/history/history_card.dart';
import 'package:restler/ui/history/sort_dialog.dart';
import 'package:restler/ui/widgets/default_app_bar.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/list_page.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';
import 'package:restler/ui/widgets/save_call_dialog.dart';

enum HistoryPageAction { search, sort, clear }

class HistoryPage extends StatefulWidget {
  const HistoryPage({
    Key key,
  }) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with StateMixin<HistoryPage> {
  final Messager _messager = kiwi();
  final _bloc = HistoryBloc();
  final _searchTextController = TextEditingController();

  @override
  void initState() {
    _messager.registerOnState(this);
    _bloc.add(HistoryFetched());
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
        title: BlocBuilder<HistoryBloc, HistoryState>(
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
                  Text(i18n.history),
                  // Counter.
                  BlocBuilder<HistoryBloc, HistoryState>(
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
        items: HistoryPageAction.values,
        itemBuilder: (context, action) {
          if (action == HistoryPageAction.search) {
            return const Icon(Icons.search);
          } else if (action == HistoryPageAction.sort) {
            return const Icon(Icons.sort);
          } else {
            return const Icon(Icons.clear_all);
          }
        },
        onItemSelected: (item) async {
          // Search.
          if (item == HistoryPageAction.search) {
            _bloc.add(SearchToggled());
          }
          // Sort.
          else if (item == HistoryPageAction.sort) {
            final res = await SortDialog.show(context, _bloc.state.sort);

            if (res != null && !res.cancelled && res.data != null) {
              _bloc.add(HistorySorted(res.data));
            }
          }
          // Clear.
          else {
            _messager.show(
              (i18n) => i18n.clearHistoryConfirmationMessage,
              actionText: i18n.yes,
              onYes: () => _bloc.add(HistoryCleared()),
            );
          }
        },
      ),
      // List.
      body: BlocBuilder<HistoryBloc, HistoryState>(
        cubit: _bloc,
        buildWhen: (a, b) => a.data != b.data,
        builder: (context, state) {
          return ListPage<HistoryEntity>(
            emptyIcon: Icons.history,
            items: state.data,
            itemBuilder: (context, i, item) {
              // Card.
              return HistoryCard(
                history: item,
                key: Key(item.uid),
                onTap: () {
                  // Fecha a tela e retorna o item que deseja abrir.
                  Navigator.pop(context, item);
                },
                onActionSelected: (action) async {
                  // Save.
                  if (action == HistoryCardAction.save) {
                    final res =
                        await SaveCallDialog.show(context, i18n.save, '');

                    if (res != null &&
                        !res.cancelled &&
                        res.data != null &&
                        res.data.length == 2) {
                      _bloc.add(HistorySaved(item, res.data[0], res.data[1]));
                    }
                  }
                  // Delete.
                  else if (action == HistoryCardAction.delete) {
                    _messager.show(
                      (i18n) => i18n.deleteHistoryConfirmationMessage,
                      actionText: i18n.yes,
                      onYes: () => _bloc.add(HistoryDeleted(item)),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
