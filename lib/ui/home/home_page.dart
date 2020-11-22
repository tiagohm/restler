import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/request/bloc.dart';
import 'package:restler/blocs/response/bloc.dart';
import 'package:restler/blocs/tab/bloc.dart';
import 'package:restler/blocs/workspace/bloc.dart';
import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/data/entities/history_entity.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/response_entity.dart';
import 'package:restler/data/entities/tab_entity.dart';
import 'package:restler/extensions.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/messager.dart';
import 'package:restler/ui/home/home_drawer.dart';
import 'package:restler/ui/home/home_tab.dart';
import 'package:restler/ui/home/method_button.dart';
import 'package:restler/ui/home/request/description_dialog.dart';
import 'package:restler/ui/home/request/request_page.dart';
import 'package:restler/ui/home/request/settings/request_settings_dialog.dart';
import 'package:restler/ui/home/response/response_page.dart';
import 'package:restler/ui/home/save_button.dart';
import 'package:restler/ui/home/scheme_button.dart';
import 'package:restler/ui/home/send_button.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/input_text_dialog.dart';
import 'package:restler/ui/widgets/label.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';
import 'package:restler/ui/widgets/save_call_dialog.dart';

enum HomeAction {
  clear,
  newTab,
  duplicateTab,
  reopenClosedTab,
  saveAs,
  settings,
  discardChanges,
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, StateMixin<HomePage> {
  final _messager = kiwi<Messager>();
  final _eventBus = kiwi<EventBus>();
  final _urlTextController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _tabBloc = TabBloc();
  final _requestBloc = RequestBloc();
  final _responseBloc = ResponseBloc();
  final _workspaceBloc = WorkspaceBloc();

  TabController _tabController;
  StreamSubscription _transitionSubscription;

  @override
  void initState() {
    _messager.registerOnState(this);

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _transitionSubscription = _eventBus.on<Transition>().listen(_onTransition);

    _dispatch(TabFetched());
    _dispatch(WorkspaceFetched());
    _dispatch(TabCallDeleted());

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _dispatch(TabCallDeleted());
    _dispatch(WorkspaceFetched());

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _messager.unregisterOnState(this);

    _transitionSubscription?.cancel();

    _requestBloc.close();
    _tabBloc.close();
    _workspaceBloc.close();

    _urlTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: HomeDrawer(
        onHistoryClosed: _open,
        onCollectionClosed: _open,
      ),
      appBar: AppBar(
        elevation: 0,
        // Hamburger.
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        // Title.
        title: BlocBuilder<TabBloc, TabState>(
          cubit: _tabBloc,
          buildWhen: (a, b) => a.tabs != b.tabs,
          builder: (context, tab) {
            return HomeTab<TabEntity>(
              initialValue: tab.currentTab,
              itemBuilder: (context, index, item) {
                return item?.name?.isNotEmpty == true ? item.name : i18n.tab;
              },
              items: tab.tabs,
              onTabSelected: (item) {
                _dispatch(TabOpened(item));
              },
              onActionSelected: (action, index, item) async {
                if (action == HomeTabAction.rename) {
                  // Exibe uma janela de diálogo para que o usuário possa renomear a aba.
                  final res = await InputTextDialog.show(
                    context,
                    item.name ?? '',
                    i18n.name,
                    i18n.tab,
                  );

                  if (res != null && !res.cancelled) {
                    _dispatch(TabRenamed(res.data));
                  }
                } else if (action == HomeTabAction.close) {
                  _dispatch(TabClosed(item));
                }
              },
            );
          },
        ),
        actions: [
          // Save.
          BlocBuilder<TabBloc, TabState>(
            cubit: _tabBloc,
            buildWhen: (a, b) =>
                a.currentTab?.saved != b.currentTab?.saved ||
                a.currentTab?.call != b.currentTab?.call,
            builder: (context, state) {
              return Visibility(
                visible: state.currentTab?.call?.isNotEmpty == true,
                child: SaveButton(
                  saved: state.currentTab.saved,
                  onPressed: () {
                    _dispatch(TabSaved());
                  },
                ),
              );
            },
          ),
          // Send.
          BlocBuilder<RequestBloc, RequestState>(
            cubit: _requestBloc,
            buildWhen: (a, b) => a.sending != b.sending,
            builder: (context, state) {
              return SendButton(
                sending: state.sending,
                onStateChanged: (sending) {
                  if (sending) {
                    _dispatch(RequestSent());
                  } else {
                    _requestBloc.state.call?.cancel(i18n.cancelled);
                  }
                },
              );
            },
          ),
          // More options.
          DotMenuButton<HomeAction>(
            items: const [
              HomeAction.newTab,
              HomeAction.duplicateTab,
              HomeAction.reopenClosedTab,
              null, // Divider.
              HomeAction.discardChanges,
              HomeAction.clear,
              null, // Divider.
              HomeAction.saveAs,
              null, // Divider.
              HomeAction.settings,
            ],
            itemBuilder: (context, index, item) {
              return ListTile(
                leading: Icon(_obtainHomeActionIcon(item)),
                title: Text(_obtainHomeActionTitle(item)),
              );
            },
            onSelected: (action) async {
              switch (action) {
                // Clear.
                case HomeAction.clear:
                  _dispatch(RequestCleared());
                  break;
                // Clear.
                case HomeAction.discardChanges:
                  _dispatch(TabReseted());
                  break;
                // New.
                case HomeAction.newTab:
                  final res = await InputTextDialog.show(
                    context,
                    null,
                    i18n.name,
                    i18n.newTab,
                  );

                  if (res != null && !res.cancelled) {
                    _open(res.data);
                  }
                  break;
                // Duplicate.
                case HomeAction.duplicateTab:
                  _dispatch(TabDuplicated());
                  break;
                // Reopen.
                case HomeAction.reopenClosedTab:
                  _dispatch(TabReopened());
                  break;
                // Save As...
                case HomeAction.saveAs:
                  final res = await SaveCallDialog.show(
                    context,
                    i18n.saveAs,
                    _tabBloc.state.currentTab.name,
                  );

                  if (res != null &&
                      !res.cancelled &&
                      res.data != null &&
                      res.data.length == 2) {
                    _dispatch(TabSavedAs(res.data[0], res.data[1]));
                  }
                  break;
                // Settings.
                case HomeAction.settings:
                  final request = _tabBloc.state.currentTab.request;

                  final res = await RequestSettingsDialog.show(
                    context,
                    request.settings,
                  );

                  if (res != null && !res.cancelled && res.data != null) {
                    _dispatch(RequestSettingsEdited(res.data));
                  }
                  break;
                default:
                  // nada.
                  break;
              }
            },
          ),
        ],
        // URL.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: <Widget>[
                                // Method.
                                BlocBuilder<RequestBloc, RequestState>(
                                  cubit: _requestBloc,
                                  buildWhen: (a, b) =>
                                      a.request.method != b.request.method,
                                  builder: (context, state) {
                                    return MethodButton(
                                      initialValue: state.request.method,
                                      onChanged: (method) async {
                                        if (method == 'CUSTOM') {
                                          // Exibe uma janela de diálogo para digitar um método.
                                          final res =
                                              await InputTextDialog.show(
                                            context,
                                            _requestBloc.state.request.method,
                                            i18n.name,
                                            i18n.httpMethod,
                                            uppercase: true,
                                          );

                                          if (res != null &&
                                              !res.cancelled &&
                                              res.data != null) {
                                            _dispatch(MethodChanged(res.data));
                                          }
                                        } else {
                                          _dispatch(MethodChanged(method));
                                        }
                                      },
                                    );
                                  },
                                ),
                                // Scheme.
                                BlocBuilder<RequestBloc, RequestState>(
                                  cubit: _requestBloc,
                                  buildWhen: (a, b) =>
                                      a.request.scheme != b.request.scheme,
                                  builder: (context, state) {
                                    return SchemeButton(
                                      initialValue: state.request.scheme,
                                      onChanged: (scheme) {
                                        _dispatch(SchemeChanged(scheme));
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            // Description.
                            IconButton(
                              icon: const Icon(Icons.description),
                              onPressed: () async {
                                final res = await DescriptionDialog.show(
                                  context,
                                  _requestBloc.state.request.description,
                                );

                                if (res != null && !res.cancelled) {
                                  _dispatch(DescriptionChanged(res.data));
                                }
                              },
                            ),
                          ],
                        ),
                        // URL.
                        Row(
                          children: [
                            Expanded(
                              child: PowerfulTextField(
                                controller: _urlTextController,
                                onChanged: (text) {
                                  _dispatch(UrlChanged(text));
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'URL',
                                  contentPadding: EdgeInsets.only(
                                    left: 8,
                                    top: 4,
                                    bottom: 4,
                                  ),
                                ),
                                keyboardType: TextInputType.url,
                                suggestionsCallback: variableSuggestions,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Material(
        color: Theme.of(context).primaryColor,
        child: Stack(
          children: <Widget>[
            Column(
              children: [
                // Abas.
                TabBar(
                  controller: _tabController,
                  tabs: [
                    // Request.
                    Tab(
                      text: i18n.request.toUpperCase(),
                    ),
                    // Response.
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(i18n.response.toUpperCase()),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Status.
                              BlocBuilder<ResponseBloc, ResponseState>(
                                cubit: _responseBloc,
                                buildWhen: (a, b) =>
                                    a.response.status != b.response.status,
                                builder: (context, state) {
                                  return Label(
                                    text: state.response.status >= 0
                                        ? '${state.response.status}'
                                        : i18n.error.toUpperCase(),
                                    color: state.response.status.statusColor,
                                  );
                                },
                              ),
                              Container(width: 4),
                              // Time.
                              BlocBuilder<ResponseBloc, ResponseState>(
                                cubit: _responseBloc,
                                buildWhen: (a, b) =>
                                    a.response.time != b.response.time,
                                builder: (context, state) {
                                  return Label(
                                    text: '${state.response.time} ms',
                                    color: Theme.of(context).indicatorColor,
                                  );
                                },
                              ),
                              Container(width: 4),
                              // Size.
                              BlocBuilder<ResponseBloc, ResponseState>(
                                cubit: _responseBloc,
                                buildWhen: (a, b) =>
                                    a.response.size != b.response.size,
                                builder: (context, state) {
                                  return Label(
                                    text: '${state.response.size} B',
                                    color: Theme.of(context).indicatorColor,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Content.
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      RequestPage(bloc: _requestBloc),
                      ResponsePage(bloc: _responseBloc),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return BlocProvider.value(
      value: _workspaceBloc,
      child: scaffold,
    );
  }

  void _onTransition(Transition transition) {
    final event = transition.event;
    final current = transition.currentState;
    final next = transition.nextState;

    // Uma aba foi aberta. Recarregar a requisição.
    // Uma aba foi fechada. Recarregar a requisição de outra aba.
    // Uma aba foi resetada para seus valores salvos atualmente no banco.
    if (event is TabOpened ||
        event is TabClosed ||
        event is TabFetched ||
        event is TabReseted) {
      _dispatch(RequestLoaded(next.currentTab.request));
      _dispatch(ResponseLoaded(next.currentTab.response));
    }
    // Qualquer evento de edição de requisição, marca como não salva uma aba.
    if (event is RequestEvent &&
        event is! RequestLoaded &&
        event is! RequestSent &&
        event is! RequestStopped) {
      _dispatch(TabEdited(request: next.request));
    }
    // Setar a URL quando uma requisição for recarregada.
    if (event is RequestLoaded || event is RequestCleared) {
      _urlTextController.text = next.request.url;
    }
    // Limpar a resposta quando a requisição for limpa.
    if (event is RequestCleared) {
      _dispatch(ResponseLoaded(ResponseEntity.empty));
    }
    // Uma requisição acabou de ser enviada.
    if (event is RequestSent) {
      if (current.response != next.response) {
        _dispatch(ResponseLoaded(next.response));
        _dispatch(TabEdited(response: next.response));
      }
      // Iniciou o envio.
      if (current.sending) {
        // Move para a aba Response.
        _tabController.index = 1;
      }
    }
    // Um workspace foi excluído.
    if (event is WorkspaceDeleted || event is WorkspaceCleared) {
      _dispatch(TabCallDeleted());
    }
    // Um workspace foi selecionado.
    if (event is WorkspaceSelected) {
      _dispatch(TabFetched());
    }
    // Um ambiente foi selecionado.
    if (event is EnvironmentSelected) {
      // nada.
    }
  }

  IconData _obtainHomeActionIcon(HomeAction action) {
    switch (action) {
      case HomeAction.clear:
        return Mdi.broom;
      case HomeAction.discardChanges:
        return Icons.undo;
      case HomeAction.newTab:
      case HomeAction.duplicateTab:
        return Mdi.tabPlus;
      case HomeAction.reopenClosedTab:
        return Mdi.tab;
      case HomeAction.saveAs:
        return Mdi.saveAs;
      case HomeAction.settings:
        return Icons.settings;
      default:
        return null;
    }
  }

  String _obtainHomeActionTitle(HomeAction action) {
    switch (action) {
      case HomeAction.clear:
        return i18n.clear;
      case HomeAction.discardChanges:
        return i18n.discardChanges;
      case HomeAction.newTab:
        return i18n.newTab;
      case HomeAction.duplicateTab:
        return i18n.duplicateTab;
      case HomeAction.reopenClosedTab:
        return i18n.reopenClosedTab;
      case HomeAction.saveAs:
        return i18n.saveAs;
      case HomeAction.settings:
        return i18n.settings;
      default:
        return null;
    }
  }

  void _open(item) {
    if (item == null) {
      return;
    }

    // Se o menu estiver aberto, fecha-o.
    if (_scaffoldKey.currentState.isDrawerOpen) {
      Navigator.pop(context);
    }

    RequestEntity request;
    ResponseEntity response;
    String name;

    if (item is HistoryEntity) {
      name = i18n.tab;
      request = item.request.clone();
      response = item.response;
    } else if (item is CallEntity) {
      name = item.name;
      request = item.request.clone();
      response = ResponseEntity.empty;
    } else if (item is String) {
      name = item;
      request = RequestEntity.empty.copyWith(uid: generateUuid());
      response = ResponseEntity.empty;
    } else {
      return;
    }

    _dispatch(
      TabOpened(
        TabEntity(
          uid: generateUuid(),
          request: request,
          response: response,
          openedAt: currentMillis(),
          saved: true,
          call: item is CallEntity ? item.uid : null,
          name: name,
        ),
        createNew: true,
      ),
    );
  }

  void _dispatch(event) {
    if (event is RequestEvent) {
      _requestBloc.add(event);
    } else if (event is TabEvent) {
      _tabBloc.add(event);
    } else if (event is ResponseEvent) {
      _responseBloc.add(event);
    } else if (event is WorkspaceEvent) {
      _workspaceBloc.add(event);
    }
  }
}
