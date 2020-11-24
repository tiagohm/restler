import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/sse/bloc.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/messager.dart';
import 'package:restler/ui/sse/response/sse_response_page.dart';
import 'package:restler/ui/widgets/checkable_tab.dart';
import 'package:restler/ui/widgets/default_app_bar.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/powerful_text_field.dart';

enum SsePageAction { search, connect }

class SsePage extends StatefulWidget {
  const SsePage({
    Key key,
  }) : super(key: key);

  @override
  _SseState createState() => _SseState();
}

class _SseState extends State<SsePage>
    with SingleTickerProviderStateMixin, StateMixin<SsePage> {
  final Messager _messager = kiwi();
  final SseBloc _bloc = kiwi();
  TextEditingController _searchTextController;
  TextEditingController _uriTextController;
  TabController _tabController;

  @override
  void initState() {
    _messager.registerOnState(this);

    _searchTextController = TextEditingController(text: _bloc.state.searchText);
    _uriTextController = TextEditingController(text: _bloc.state.uri);

    _tabController = TabController(
      length: 1,
      vsync: this,
    );

    super.initState();
  }

  @override
  void dispose() {
    _messager.unregisterOnState(this);
    _searchTextController.dispose();
    _uriTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        onBack: () => true,
        // Title.
        title: BlocBuilder<SseBloc, SseState>(
          key: const Key('sse-title'),
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
                  const Text('SSE'),
                ],
              );
            }
          },
        ),
        items: SsePageAction.values,
        itemBuilder: (context, action) {
          if (action == SsePageAction.search) {
            return const Icon(Icons.search);
          } else if (action == SsePageAction.connect) {
            return BlocBuilder<SseBloc, SseState>(
              key: const Key('sse-state-icon'),
              cubit: _bloc,
              buildWhen: (a, b) => a.connected != b.connected,
              builder: (context, state) {
                return state.connected
                    ? const Icon(Icons.cancel)
                    : const Icon(Mdi.disconnected);
              },
            );
          } else {
            return const Icon(Icons.send);
          }
        },
        onItemSelected: (item) async {
          // Search.
          if (item == SsePageAction.search) {
            _bloc.add(SearchToggled());
          }
          // Connect.
          else if (item == SsePageAction.connect) {
            if (_bloc.state.connected) {
              _bloc.add(Disconnected());
            } else {
              _bloc.add(Connected());
            }
          }
        },
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    // URL.
                    child: Row(
                      children: [
                        Expanded(
                          child: PowerfulTextField(
                            controller: _uriTextController,
                            onChanged: (text) {
                              _bloc.add(UriChanged(text));
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: 'URL',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Tabs (height: 48px).
              TabBar(
                isScrollable: true,
                controller: _tabController,
                tabs: <Widget>[
                  // Response.
                  BlocBuilder<SseBloc, SseState>(
                    key: const Key('sse-tab-response'),
                    cubit: _bloc,
                    buildWhen: (a, b) {
                      return a.filteredMessages.length !=
                          b.filteredMessages.length;
                    },
                    builder: (context, state) {
                      return CheckableTab(
                        title: Text(i18n.response.toUpperCase()),
                        badgeCount: state.filteredMessages.length,
                        isCheckable: false,
                        items: const [0],
                        itemBuilder: (context, i, item) {
                          return ListTile(
                            leading: Icon(_obtainActionIcon(item)),
                            title: Text(_obtainActionName(item)),
                          );
                        },
                        onItemSelected: (item) {
                          if (item == 0) {
                            _bloc.add(MessageCleared());
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          // Response.
          BlocBuilder<SseBloc, SseState>(
            key: const Key('sse-content-response'),
            cubit: _bloc,
            buildWhen: (a, b) => a.filteredMessages != b.filteredMessages,
            builder: (context, state) {
              return SseResponsePage(
                items: state.filteredMessages,
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _obtainActionIcon(int action) {
    switch (action) {
      case 0:
        return Mdi.broom;
      default:
        return null;
    }
  }

  String _obtainActionName(int action) {
    switch (action) {
      case 0:
        return i18n.clear;
      default:
        return null;
    }
  }
}
