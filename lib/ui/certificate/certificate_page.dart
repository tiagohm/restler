import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/certificate/bloc.dart';
import 'package:restler/data/entities/certificate_entity.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/messager.dart';
import 'package:restler/ui/certificate/certificate_card.dart';
import 'package:restler/ui/certificate/create_edit_certificate_dialog.dart';
import 'package:restler/ui/widgets/default_app_bar.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/list_page.dart';
import 'package:restler/ui/widgets/move_to_workspace_dialog.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

enum CertificatePageAction { search, clear }

class CertificatePage extends StatefulWidget {
  const CertificatePage({
    Key key,
  }) : super(key: key);

  @override
  _CertificatePageState createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage>
    with StateMixin<CertificatePage> {
  final _messager = kiwi<Messager>();
  final _bloc = CertificateBloc();
  final _searchTextController = TextEditingController();

  @override
  void initState() {
    _messager.registerOnState(this);
    _bloc.add(CertificateFetched());
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
        title: BlocBuilder<CertificateBloc, CertificateState>(
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
                  Text(i18n.certificate),
                  // Counter.
                  BlocBuilder<CertificateBloc, CertificateState>(
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
        items: CertificatePageAction.values,
        itemBuilder: (context, action) {
          if (action == CertificatePageAction.search) {
            return const Icon(Icons.search);
          } else {
            return const Icon(Icons.clear_all);
          }
        },
        onItemSelected: (item) async {
          // Search.
          if (item == CertificatePageAction.search) {
            _bloc.add(SearchToggled());
          }
          // Clear.
          else {
            _messager.show(
              (i18n) => i18n.clearCertificateConfirmationMessage,
              actionText: i18n.yes,
              onYes: () => _bloc.add(CertificateCleared()),
            );
          }
        },
      ),
      // List.
      body: BlocBuilder<CertificateBloc, CertificateState>(
        cubit: _bloc,
        buildWhen: (a, b) => a.data != b.data,
        builder: (context, state) {
          return ListPage<CertificateEntity>(
            emptyIcon: Mdi.certificate,
            items: state.data,
            itemBuilder: (context, i, item) {
              // Card.
              return CertificateCard(
                certificate: item,
                key: Key(item.uid),
                // Enabled.
                onEnabled: (enabled) {
                  _bloc.add(
                    CertificateEdited(item.copyWith(enabled: !item.enabled)),
                  );
                },
                onActionSelected: (action) async {
                  // Edit.
                  if (action == CertificateCardAction.edit) {
                    final res =
                        await CreateEditCertificateDialog.show(context, item);

                    if (res != null && !res.cancelled && res.data != null) {
                      _bloc.add(CertificateEdited(res.data));
                    }
                  }
                  // Duplicated.
                  else if (action == CertificateCardAction.duplicate) {
                    _bloc.add(CertificateDuplicated(item));
                  }
                  // Move.
                  else if (action == CertificateCardAction.move) {
                    final res = await MoveToWorkspaceDialog.show(
                      context,
                      item.workspace,
                      i18n.moveCertificate,
                    );

                    if (res != null && !res.cancelled && res.data != null) {
                      _bloc.add(CertificateMoved(item, res.data));
                    }
                  }
                  // Copy.
                  else if (action == CertificateCardAction.copy) {
                    final res = await MoveToWorkspaceDialog.show(
                      context,
                      item.workspace,
                      i18n.copyCertificate,
                    );

                    if (res != null && !res.cancelled && res.data != null) {
                      _bloc.add(CertificateCopied(item, res.data));
                    }
                  }
                  // Delete.
                  else if (action == CertificateCardAction.delete) {
                    _messager.show(
                      (i18n) => i18n.deleteCertificateConfirmationMessage,
                      actionText: i18n.yes,
                      onYes: () => _bloc.add(CertificateDeleted(item)),
                    );
                  }
                },
              );
            },
            // Add.
            onAdded: () async {
              final res = await CreateEditCertificateDialog.show(context, null);

              if (res != null && !res.cancelled && res.data != null) {
                _bloc.add(CertificateCreated(res.data));
              }
            },
          );
        },
      ),
    );
  }
}
