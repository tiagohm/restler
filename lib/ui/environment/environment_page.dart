import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/environment/bloc.dart';
import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/i18n.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/messager.dart';
import 'package:restler/router.dart';
import 'package:restler/ui/environment/copy_environment_dialog.dart';
import 'package:restler/ui/environment/create_edit_environment_dialog.dart';
import 'package:restler/ui/environment/environment_card.dart';
import 'package:restler/ui/widgets/default_app_bar.dart';
import 'package:restler/ui/widgets/list_page.dart';
import 'package:restler/ui/widgets/move_to_workspace_dialog.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

enum EnvironmentPageAction { search, clear }

class EnvironmentPage extends StatefulWidget {
  const EnvironmentPage({
    Key key,
  }) : super(key: key);

  @override
  _EnvironmentPageState createState() => _EnvironmentPageState();
}

class _EnvironmentPageState extends State<EnvironmentPage> {
  final Messager _messager = kiwi();
  final _bloc = EnvironmentBloc();
  final _searchTextController = TextEditingController();

  @override
  void initState() {
    _messager.registerOnState(this);
    _bloc.add(EnvironmentFetched());
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
    final i18n = I18n.of(context);

    return Scaffold(
      appBar: DefaultAppBar(
        onBack: () => true,
        // Title.
        title: BlocBuilder<EnvironmentBloc, EnvironmentState>(
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
                  Text(i18n.environment),
                  // Counter.
                  BlocBuilder<EnvironmentBloc, EnvironmentState>(
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
        items: EnvironmentPageAction.values,
        itemBuilder: (context, action) {
          if (action == EnvironmentPageAction.search) {
            return const Icon(Icons.search);
          } else {
            return const Icon(Icons.clear_all);
          }
        },
        onItemSelected: (item) async {
          // Search.
          if (item == EnvironmentPageAction.search) {
            _bloc.add(SearchToggled());
          }
          // Clear.
          else {
            _messager.show(
              (i18n) => i18n.clearEnvironmentConfirmationMessage,
              actionText: i18n.yes,
              onYes: () => _bloc.add(EnvironmentCleared()),
            );
          }
        },
      ),
      // List.
      body: BlocBuilder<EnvironmentBloc, EnvironmentState>(
        cubit: _bloc,
        buildWhen: (a, b) => a.data != b.data,
        builder: (context, state) {
          return ListPage<EnvironmentEntity>(
            emptyIcon: Mdi.environment,
            items: state.data,
            itemBuilder: (context, i, item) {
              // Card.
              return EnvironmentCard(
                environment: item,
                key: Key(item.uid),
                onTap: () => navigateVariable(item),
                onActionSelected: (action) async {
                  // Edit.
                  if (action == EnvironmentCardAction.edit) {
                    final res = await CreateEditEnvironmentDialog.show(
                      context,
                      item,
                    );

                    if (res != null && !res.cancelled && res.data != null) {
                      _bloc.add(
                        EnvironmentEdited(item.copyWith(name: res.data)),
                      );
                    }
                  }
                  // Duplicate.
                  else if (action == EnvironmentCardAction.duplicate) {
                    _bloc.add(EnvironmentDuplicated(item));
                  }
                  // Move.
                  else if (action == EnvironmentCardAction.move) {
                    final res = await MoveToWorkspaceDialog.show(
                      context,
                      item.workspace,
                      i18n.moveEnvironment,
                    );

                    if (res != null && !res.cancelled) {
                      _bloc.add(EnvironmentMoved(item, res.data));
                    }
                  }
                  // Copy.
                  else if (action == EnvironmentCardAction.copy) {
                    final res = await CopyEnvironmentDialog.show(context, item);

                    if (res != null && !res.cancelled) {
                      _bloc.add(
                        EnvironmentCopied(item, res.data[0], res.data[1]),
                      );
                    }
                  }
                  // Delete.
                  else if (action == EnvironmentCardAction.delete) {
                    _messager.show(
                      (i18n) => i18n.deleteEnvironmentConfirmationMessage,
                      actionText: i18n.yes,
                      onYes: () => _bloc.add(EnvironmentDeleted(item)),
                    );
                  }
                },
              );
            },
            // Add.
            onAdded: () async {
              final res = await CreateEditEnvironmentDialog.show(context, null);

              if (res != null && !res.cancelled && res.data != null) {
                _bloc.add(EnvironmentCreated(res.data));
              }
            },
          );
        },
      ),
    );
  }
}
