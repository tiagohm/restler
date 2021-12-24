import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/request/settings/bloc.dart';
import 'package:restler/data/entities/dns_entity.dart';
import 'package:restler/data/entities/proxy_entity.dart';
import 'package:restler/data/entities/request_settings_entity.dart';
import 'package:restler/inject.dart';
import 'package:restler/mdi.dart';
import 'package:restler/settings.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/labeled_checkbox.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class RequestSettingsDialog extends StatefulWidget {
  final RequestSettingsEntity settings;
  final bool isRest;

  const RequestSettingsDialog({
    Key key,
    @required this.settings,
    @required this.isRest,
  }) : super(key: key);

  static Future<DialogResult<RequestSettingsEntity>> show(
    BuildContext context,
    RequestSettingsEntity settings, {
    @required bool isRest,
  }) async {
    return showDialog<DialogResult<RequestSettingsEntity>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RequestSettingsDialog(
        settings: settings,
        isRest: isRest,
      ),
    );
  }

  @override
  _RequestSettingsDialogState createState() => _RequestSettingsDialogState();
}

class _RequestSettingsDialogState extends State<RequestSettingsDialog>
    with StateMixin<RequestSettingsDialog> {
  final _bloc = RequestSettingsBloc();
  final _formKey = GlobalKey<FormState>();
  final _settings = kiwi<Settings>();

  @override
  void initState() {
    _bloc.add(Started(widget.settings));
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<RequestSettingsEntity>(
      title: i18n.settings,
      onCancel: () => null,
      onDone: () {
        return _bloc.state.settings;
      },
      bodyBuilder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 4),
          child: Form(
            key: _formKey,
            child: ListBody(
              children: [
                // Proxy.
                BlocBuilder<RequestSettingsBloc, RequestSettingsState>(
                  key: const Key('request-settings-proxy'),
                  cubit: _bloc,
                  buildWhen: (a, b) {
                    return a.settings.proxy != b.settings.proxy ||
                        a.proxies != b.proxies;
                  },
                  builder: (context, state) {
                    return DropdownButtonFormField<ProxyEntity>(
                      key: Key(state.settings.proxy?.uid),
                      decoration: InputDecoration(
                        icon: const Icon(Mdi.serverNetwork),
                        labelText: i18n.proxy,
                      ),
                      items: _mapProxyEntityToDropdownItem(state.proxies),
                      value: state.settings.proxy,
                      onChanged: (item) {
                        _bloc.add(RequestSettingsChanged(proxy: item));
                      },
                      style: defaultInputTextStyle,
                    );
                  },
                ),
                // Dns.
                BlocBuilder<RequestSettingsBloc, RequestSettingsState>(
                  key: const Key('request-settings-dns'),
                  cubit: _bloc,
                  buildWhen: (a, b) {
                    return a.settings.dns != b.settings.dns || a.dnss != b.dnss;
                  },
                  builder: (context, state) {
                    return DropdownButtonFormField<DnsEntity>(
                      key: Key(state.settings.dns?.uid),
                      decoration: InputDecoration(
                        icon: const Icon(Icons.dns),
                        labelText: i18n.dns,
                      ),
                      items: _mapDnsEntityToDropdownItem(state.dnss),
                      value: state.settings.dns,
                      onChanged: (item) {
                        _bloc.add(RequestSettingsChanged(dns: item));
                      },
                      style: defaultInputTextStyle,
                    );
                  },
                ),
                // Send cookies.
                BlocBuilder<RequestSettingsBloc, RequestSettingsState>(
                  key: const Key('request-settings-send-cookies'),
                  cubit: _bloc,
                  buildWhen: (a, b) {
                    return a.settings.sendCookies != b.settings.sendCookies;
                  },
                  builder: (context, state) {
                    return LabeledCheckbox(
                      value: state.settings.sendCookies,
                      text: i18n.sendCookies,
                      onChanged: (enabled) {
                        _bloc.add(RequestSettingsChanged(
                          sendCookies: enabled,
                        ));
                      },
                    );
                  },
                ),
                // Store cookies.
                BlocBuilder<RequestSettingsBloc, RequestSettingsState>(
                  key: const Key('request-settings-store-cookies'),
                  cubit: _bloc,
                  buildWhen: (a, b) {
                    return a.settings.storeCookies != b.settings.storeCookies;
                  },
                  builder: (context, state) {
                    return LabeledCheckbox(
                      value: state.settings.storeCookies,
                      text: i18n.storeCookies,
                      onChanged: (enabled) {
                        _bloc.add(RequestSettingsChanged(
                          storeCookies: enabled,
                        ));
                      },
                    );
                  },
                ),
                // Cache.
                BlocBuilder<RequestSettingsBloc, RequestSettingsState>(
                  key: const Key('request-settings-cache'),
                  cubit: _bloc,
                  buildWhen: (a, b) {
                    return a.settings.cache != b.settings.cache;
                  },
                  builder: (context, state) {
                    return LabeledCheckbox(
                      value: widget.isRest && state.settings.cache,
                      text: i18n.cache,
                      onChanged: !widget.isRest || !_settings.cacheEnabled
                          ? null
                          : (enabled) {
                              _bloc.add(
                                RequestSettingsChanged(cache: enabled),
                              );
                            },
                    );
                  },
                ),
                // Enable Variables.
                BlocBuilder<RequestSettingsBloc, RequestSettingsState>(
                  key: const Key('request-settings-variables'),
                  cubit: _bloc,
                  buildWhen: (a, b) {
                    return a.settings.enableVariables !=
                        b.settings.enableVariables;
                  },
                  builder: (context, state) {
                    return LabeledCheckbox(
                      value: state.settings.enableVariables,
                      text: i18n.enableVariables,
                      onChanged: (enabled) {
                        _bloc.add(RequestSettingsChanged(
                          enableVariables: enabled,
                        ));
                      },
                    );
                  },
                ),
                // Keep Equal Sign For Empty Query.
                BlocBuilder<RequestSettingsBloc, RequestSettingsState>(
                  key: const Key('request-settings-queries'),
                  cubit: _bloc,
                  buildWhen: (a, b) {
                    return a.settings.keepEqualSign != b.settings.keepEqualSign;
                  },
                  builder: (context, state) {
                    return LabeledCheckbox(
                      value: state.settings.keepEqualSign,
                      text: i18n.keepEqualSignForEmptyQuery,
                      onChanged: !widget.isRest
                          ? null
                          : (enabled) {
                              _bloc.add(RequestSettingsChanged(
                                keepEqualSign: enabled,
                              ));
                            },
                    );
                  },
                ),
                // Disable Persistent Connection.
                BlocBuilder<RequestSettingsBloc, RequestSettingsState>(
                  key: const Key('request-settings-persitent'),
                  cubit: _bloc,
                  buildWhen: (a, b) {
                    return a.settings.persistentConnection !=
                        b.settings.persistentConnection;
                  },
                  builder: (context, state) {
                    return LabeledCheckbox(
                      value: state.settings.persistentConnection,
                      text: i18n.persistentConnection,
                      onChanged: (enabled) {
                        _bloc.add(RequestSettingsChanged(
                          persistentConnection: enabled,
                        ));
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<DropdownMenuItem<ProxyEntity>> _mapProxyEntityToDropdownItem(
    List<ProxyEntity> data,
  ) {
    return [
      for (final item in data)
        DropdownMenuItem<ProxyEntity>(
          value: item,
          child: Container(
            height: 32,
            width: 150,
            child: Row(
              children: <Widget>[
                Text(item.uid == null ? i18n.none : item.name ?? i18n.unnamed),
              ],
            ),
          ),
        ),
    ];
  }

  List<DropdownMenuItem<DnsEntity>> _mapDnsEntityToDropdownItem(
    List<DnsEntity> data,
  ) {
    return [
      for (final item in data)
        DropdownMenuItem<DnsEntity>(
          value: item,
          child: Container(
            height: 32,
            width: 150,
            child: Row(
              children: <Widget>[
                Text(item.uid == null ? i18n.none : item.name ?? i18n.unnamed),
              ],
            ),
          ),
        ),
    ];
  }
}
