import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:restler/blocs/settings/bloc.dart';
import 'package:restler/blocs/workspace/bloc.dart';
import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/history_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/messager.dart';
import 'package:restler/router.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/home/about_dialog.dart';
import 'package:restler/ui/home/donation_dialog.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/input_text_dialog.dart';
import 'package:restler/ui/widgets/separator.dart';

enum WorkspaceAction { add, edit, delete, clear, duplicate }

class HomeDrawer extends StatefulWidget {
  final ValueChanged<HistoryEntity> onHistoryClosed;
  final ValueChanged onCollectionClosed;

  const HomeDrawer({
    Key key,
    this.onHistoryClosed,
    this.onCollectionClosed,
  }) : super(key: key);

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> with StateMixin<HomeDrawer> {
  final SettingsBloc _settingsBloc = kiwi();
  final Messager _messager = kiwi();
  WorkspaceBloc _workspaceBloc;

  @override
  void initState() {
    _workspaceBloc = BlocProvider.of<WorkspaceBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          // Drawer.
          Container(
            color: Colors.orange,
            height: MediaQuery.of(context).padding.top + 136,
            padding: const EdgeInsets.only(left: 16, right: 8, bottom: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // Workspaces.
                Row(
                  children: <Widget>[
                    // Logo.
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        width: 36,
                        height: 36,
                      ),
                    ),
                    // List.
                    Expanded(
                      child: BlocBuilder<WorkspaceBloc, WorkspaceState>(
                        builder: (context, state) {
                          return DropdownButton<WorkspaceEntity>(
                            items: mapWorkspaceEntityToDropdownItem(
                              state.workspaces,
                              style: defaultInputTextStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onChanged: (value) {
                              _workspaceBloc.add(WorkspaceSelected(value));
                            },
                            value: state.currentWorkspace,
                            underline: Container(),
                            isExpanded: true,
                          );
                        },
                      ),
                    ),
                    // Options.
                    DotMenuButton<WorkspaceAction>(
                      items: [
                        WorkspaceAction.add,
                        WorkspaceAction.edit,
                        WorkspaceAction.duplicate,
                        null, // Divider.
                        WorkspaceAction.clear,
                        null, // Divider.
                        WorkspaceAction.delete,
                      ],
                      itemBuilder: (context, index, action) {
                        return ListTile(
                          leading: Icon(_obtainWorkspaceActionIcon(action)),
                          title: Text(_obtainWorkspaceActionName(action)),
                        );
                      },
                      onSelected: (action) async {
                        // Add.
                        if (action == WorkspaceAction.add) {
                          final res = await InputTextDialog.show(
                            context,
                            '',
                            i18n.name,
                            i18n.newWorkspace,
                          );

                          if (!res.cancelled) {
                            _workspaceBloc.add(WorkspaceCreated(res.data));
                          }
                        }
                        // Edit.
                        else if (action == WorkspaceAction.edit) {
                          final workspace =
                              _workspaceBloc.state.currentWorkspace;

                          if (workspace?.uid != null) {
                            final res = await InputTextDialog.show(
                              context,
                              workspace.name,
                              i18n.name,
                              i18n.editWorkspace,
                            );

                            if (!res.cancelled) {
                              _workspaceBloc.add(WorkspaceEdited(res.data));
                            }
                          } else {
                            _messager.show(
                              (i18n) => i18n.defaultWorkspaceCantBeEdited,
                            );
                          }
                        }
                        // Duplicate.
                        else if (action == WorkspaceAction.duplicate) {
                          _workspaceBloc.add(WorkspaceDuplicated());
                        }
                        // Delete.
                        else if (action == WorkspaceAction.delete) {
                          final workspace =
                              _workspaceBloc.state.currentWorkspace;

                          if (workspace?.uid != null) {
                            _messager.show(
                              (i18n) => i18n.deleteWorkspaceConfirmationMessage,
                              actionText: i18n.yes,
                              onYes: () {
                                _workspaceBloc.add(WorkspaceDeleted());
                              },
                            );
                          } else {
                            _messager.show(
                              (i18n) => i18n.defaultWorkspaceCantBeDeleted,
                            );
                          }
                        }
                        // Clear.
                        else if (action == WorkspaceAction.clear) {
                          _messager.show(
                            (i18n) => i18n.clearWorkspaceConfirmationMessage,
                            actionText: i18n.yes,
                            onYes: () => _workspaceBloc.add(WorkspaceCleared()),
                          );
                        }
                      },
                    ),
                  ],
                ),
                Container(height: 8),
                // Environments.
                Row(
                  children: <Widget>[
                    // List.
                    Expanded(
                      child: BlocBuilder<WorkspaceBloc, WorkspaceState>(
                        builder: (context, state) {
                          return Container(
                            decoration: ShapeDecoration(
                              color: Colors.orange[400],
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  color: Colors.orange,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: DropdownButton<EnvironmentEntity>(
                                items: _mapEnvironmentEntityToDropdownItem(
                                  state.environments,
                                ),
                                onChanged: (value) {
                                  _workspaceBloc
                                      .add(EnvironmentSelected(value));
                                },
                                value: state.currentEnvironment,
                                underline: Container(),
                                isExpanded: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Options.
                    const IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: navigateEnvironment,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              children: <Widget>[
                // Web Socket.
                ListTile(
                  // Icon.
                  leading: const Icon(Mdi.web),
                  // Title.
                  title: Text(i18n.webSocket),
                  onTap: navigateToWebSocket,
                ),
                // SSE.
                const ListTile(
                  // Icon.
                  leading: Icon(Mdi.web),
                  // Title.
                  title: Text('SSE'),
                  onTap: navigateToSse,
                ),
                Separator(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                ),
                // History.
                ListTile(
                  // Icon.
                  leading: const Icon(Icons.history),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Title.
                      Text(i18n.history),
                      // Enabled.
                      BlocBuilder<SettingsBloc, SettingsState>(
                        cubit: _settingsBloc,
                        buildWhen: (a, b) =>
                            a.historyEnabled != b.historyEnabled,
                        builder: (context, state) {
                          return Switch(
                            value: state.historyEnabled,
                            onChanged: (enabled) {
                              _settingsBloc
                                  .add(SettingsEdited(historyEnabled: enabled));
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () async {
                    final data = await navigateToHistory();
                    widget.onHistoryClosed?.call(data);
                  },
                ),
                // Collection.
                ListTile(
                  // Icon.
                  leading: const Icon(Icons.folder),
                  // Title.
                  title: Text(i18n.collection),
                  onTap: () async {
                    final data = await navigateToCollection();
                    widget.onCollectionClosed?.call(data);
                  },
                ),
                // Cookie.
                ListTile(
                  // Icon.
                  leading: const Icon(Mdi.cookie),
                  // Title.
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Title.
                      Text(i18n.cookie),
                      // Enabled.
                      BlocBuilder<SettingsBloc, SettingsState>(
                        cubit: _settingsBloc,
                        buildWhen: (a, b) => a.cookieEnabled != b.cookieEnabled,
                        builder: (context, state) {
                          return Switch(
                            value: state.cookieEnabled,
                            onChanged: (enabled) {
                              _settingsBloc.add(
                                SettingsEdited(cookieEnabled: enabled),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: navigateToCookie,
                ),
                // Certificate.
                ListTile(
                  // Icon.
                  leading: const Icon(Mdi.certificate),
                  // Title.
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Title.
                      Text(i18n.certificate),
                      // Enabled.
                      BlocBuilder<SettingsBloc, SettingsState>(
                        cubit: _settingsBloc,
                        buildWhen: (a, b) =>
                            a.certificateEnabled != b.certificateEnabled,
                        builder: (context, state) {
                          return Switch(
                            value: state.certificateEnabled,
                            onChanged: (enabled) {
                              _settingsBloc.add(
                                SettingsEdited(certificateEnabled: enabled),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: navigateToCertificate,
                ),
                // Proxy.
                ListTile(
                  // Icon.
                  leading: const Icon(Mdi.serverNetwork),
                  // Title.
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Title.
                      Text(i18n.proxy),
                      // Enabled.
                      BlocBuilder<SettingsBloc, SettingsState>(
                        cubit: _settingsBloc,
                        buildWhen: (a, b) => a.proxyEnabled != b.proxyEnabled,
                        builder: (context, state) {
                          return Switch(
                            value: state.proxyEnabled,
                            onChanged: (enabled) {
                              _settingsBloc.add(
                                SettingsEdited(proxyEnabled: enabled),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: navigateToProxy,
                ),
                // DNS.
                ListTile(
                  // Icon.
                  leading: const Icon(Icons.dns),
                  // Title.
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Title.
                      Text(i18n.dns),
                      // Enabled.
                      BlocBuilder<SettingsBloc, SettingsState>(
                        cubit: _settingsBloc,
                        buildWhen: (a, b) => a.dnsEnabled != b.dnsEnabled,
                        builder: (context, state) {
                          return Switch(
                            value: state.dnsEnabled,
                            onChanged: (enabled) {
                              _settingsBloc.add(
                                SettingsEdited(dnsEnabled: enabled),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: navigateToDns,
                ),
                Separator(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                ),
                // Settings.
                ListTile(
                  // Icon.
                  leading: const Icon(Icons.settings),
                  // Title.
                  title: Text(i18n.settings),
                  onTap: navigateToSettings,
                ),
                // Theme.
                ListTile(
                  // Icon.
                  leading: const Icon(Mdi.theme),
                  // Title.
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Title.
                      Text(i18n.darkTheme),
                      // Enabled.
                      BlocBuilder<SettingsBloc, SettingsState>(
                        cubit: _settingsBloc,
                        buildWhen: (a, b) => a.darkTheme != b.darkTheme,
                        builder: (context, state) {
                          return Switch(
                            value: state.darkTheme,
                            onChanged: (enabled) {
                              _settingsBloc.add(
                                SettingsEdited(darkTheme: enabled),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Separator(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.black12,
                ),
                // Donation.
                ListTile(
                  // Icon.
                  leading: const Icon(Mdi.donate),
                  // Title.
                  title: Text(i18n.donation),
                  onTap: () async {
                    final res = await DonationDialog.show(context);

                    if (!res.cancelled && res.data != null && res.data) {
                      _messager.show((i18n) => i18n.donateThankYou);
                    }
                  },
                ),
                // About.
                ListTile(
                  // Icon.
                  leading: const Icon(Icons.info),
                  // Title.
                  title: Text(i18n.about),
                  onTap: () async {
                    await AboutTheAppDialog.show(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<EnvironmentEntity>> _mapEnvironmentEntityToDropdownItem(
    List<EnvironmentEntity> data,
  ) {
    return [
      for (final item in data)
        DropdownMenuItem(
          value: item,
          child: Text(
            item.isNoEnvironment ? i18n.noEnvironment : item.name,
            style: defaultInputTextStyle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
    ];
  }

  String _obtainWorkspaceActionName(WorkspaceAction action) {
    switch (action) {
      case WorkspaceAction.add:
        return i18n.add;
      case WorkspaceAction.edit:
        return i18n.edit;
      case WorkspaceAction.duplicate:
        return i18n.duplicate;
      case WorkspaceAction.delete:
        return i18n.delete;
      case WorkspaceAction.clear:
        return i18n.clear;
      default:
        return null;
    }
  }

  IconData _obtainWorkspaceActionIcon(WorkspaceAction action) {
    switch (action) {
      case WorkspaceAction.add:
        return Icons.add;
      case WorkspaceAction.edit:
        return Icons.edit;
      case WorkspaceAction.duplicate:
        return Mdi.duplicate;
      case WorkspaceAction.delete:
        return Icons.delete;
      case WorkspaceAction.clear:
        return Mdi.broom;
      default:
        return null;
    }
  }
}
