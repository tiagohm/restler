import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/variable/bloc.dart';
import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/variable_entity.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/messager.dart';
import 'package:restler/ui/environment/variable/create_edit_variable_dialog.dart';
import 'package:restler/ui/environment/variable/variable_card.dart';
import 'package:restler/ui/widgets/default_app_bar.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/list_page.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

enum VariablePageAction { search, clear }

class VariablePage extends StatefulWidget {
  final EnvironmentEntity environment;

  const VariablePage({
    Key key,
    @required this.environment,
  }) : super(key: key);

  @override
  _VariablePageState createState() => _VariablePageState();
}

class _VariablePageState extends State<VariablePage>
    with StateMixin<VariablePage> {
  final Messager _messager = kiwi();
  final _searchTextController = TextEditingController();
  VariableBloc _bloc;

  @override
  void initState() {
    _messager.registerOnState(this);
    _bloc = VariableBloc(widget.environment);
    _bloc.add(VariableFetched());
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
        title: BlocBuilder<VariableBloc, VariableState>(
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
                  Text(widget.environment.name ?? i18n.global),
                  // Counter.
                  BlocBuilder<VariableBloc, VariableState>(
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
        items: VariablePageAction.values,
        itemBuilder: (context, action) {
          if (action == VariablePageAction.search) {
            return const Icon(Icons.search);
          } else {
            return const Icon(Icons.clear_all);
          }
        },
        onItemSelected: (item) async {
          // Search.
          if (item == VariablePageAction.search) {
            _bloc.add(SearchToggled());
          }
          // Clear.
          else {
            _messager.show(
              (i18n) => i18n.clearVariableConfirmationMessage,
              actionText: i18n.yes,
              onYes: () => _bloc.add(VariableCleared()),
            );
          }
        },
      ),
      // List.
      body: BlocBuilder<VariableBloc, VariableState>(
        cubit: _bloc,
        buildWhen: (a, b) => a.data != b.data,
        builder: (context, state) {
          return ListPage<VariableEntity>(
            emptyIcon: Mdi.variable,
            emptyText: i18n.howToUseVariable,
            items: state.data,
            itemBuilder: (context, i, item) {
              // Card.
              return VariableCard(
                variable: item,
                key: Key(item.uid),
                onActionSelected: (action) async {
                  // Edit.
                  if (action == VariableCardAction.edit) {
                    final res = await CreateEditVariableDialog.show(
                      context,
                      item,
                    );

                    if (!res.cancelled && res.data != null) {
                      _bloc.add(VariableEdited(
                        item.copyWith(
                          name: res.data[0],
                          value: res.data[1],
                          secret: res.data[2],
                        ),
                      ));
                    }
                  }
                  // Duplicated.
                  else if (action == VariableCardAction.duplicate) {
                    _bloc.add(VariableDuplicated(item));
                  }
                  // Delete.
                  else if (action == VariableCardAction.delete) {
                    _messager.show(
                      (i18n) => i18n.deleteVariableConfirmationMessage,
                      actionText: i18n.yes,
                      onYes: () => _bloc.add(VariableDeleted(item)),
                    );
                  }
                },
              );
            },
            // Add.
            onAdded: () async {
              final res = await CreateEditVariableDialog.show(context, null);

              if (!res.cancelled && res.data != null) {
                _bloc.add(VariableCreated(
                  res.data[0],
                  res.data[1],
                  res.data[2],
                ));
              }
            },
          );
        },
      ),
    );
  }
}
