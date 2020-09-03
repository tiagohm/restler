import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restler/blocs/settings/bloc.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:restler/messager.dart';
import 'package:restler/ui/widgets/action_button.dart';
import 'package:restler/ui/widgets/context_menu_button.dart';
import 'package:restler/ui/widgets/default_app_bar.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/input_text_dialog.dart';

final _availableFontSizes = List.generate(21, (i) => 10 + i);

const _availableCacheMaxSizes = [
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, //
  20, 30, 40, 50, 60, 70, 80, 90, 100 //
];

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    Key key,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with StateMixin<SettingsPage> {
  final _bloc = kiwi<SettingsBloc>();
  final _messager = kiwi<Messager>();

  @override
  void initState() {
    _messager.registerOnState(this);
    _bloc.add(SettingsStarted());
    super.initState();
  }

  @override
  void dispose() {
    _messager.unregisterOnState(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        onBack: () => true,
        // Title.
        title: Text(i18n.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Request.
              _OptionCard(
                title: i18n.request,
                children: <Widget>[
                  // Follow Redirects.
                  BlocBuilder<SettingsBloc, SettingsState>(
                    cubit: _bloc,
                    buildWhen: (a, b) => a.followRedirects != b.followRedirects,
                    builder: (context, state) {
                      return _BoolInputOption(
                        title: i18n.followRedirects,
                        value: state.followRedirects,
                        onChanged: (value) {
                          _bloc.add(SettingsEdited(followRedirects: value));
                        },
                      );
                    },
                  ),
                  // Max Redirects.
                  BlocBuilder<SettingsBloc, SettingsState>(
                    cubit: _bloc,
                    buildWhen: (a, b) => a.maxRedirects != b.maxRedirects,
                    builder: (context, state) {
                      return _TextInputOption(
                        title: i18n.maxRedirects,
                        subtitle: i18n.minusOneForInfinite,
                        value: state.maxRedirects.toString(),
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                        ),
                        onChanged: (text) {
                          final value = int.tryParse(text) ?? 0;
                          _bloc.add(SettingsEdited(maxRedirects: value));
                        },
                      );
                    },
                  ),
                  // Connection timeout.
                  BlocBuilder<SettingsBloc, SettingsState>(
                    cubit: _bloc,
                    buildWhen: (a, b) =>
                        a.connectionTimeout != b.connectionTimeout,
                    builder: (context, state) {
                      return _TextInputOption(
                        title: i18n.connectionTimeout,
                        subtitle: i18n.minusOneForInfinite,
                        value: state.connectionTimeout.toString(),
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                        ),
                        onChanged: (text) {
                          final value = int.tryParse(text) ?? 0;
                          _bloc.add(SettingsEdited(connectionTimeout: value));
                        },
                      );
                    },
                  ),
                  // Session timeout.
                  BlocBuilder<SettingsBloc, SettingsState>(
                    cubit: _bloc,
                    buildWhen: (a, b) => a.sessionTimeout != b.sessionTimeout,
                    builder: (context, state) {
                      return _TextInputOption(
                        title: i18n.sessionTimeout,
                        value: state.sessionTimeout.toString(),
                        keyboardType: const TextInputType.numberWithOptions(),
                        onChanged: (text) {
                          final value = int.tryParse(text) ?? 0;
                          _bloc.add(SettingsEdited(sessionTimeout: value));
                        },
                      );
                    },
                  ),
                  // Validate Certificates.
                  BlocBuilder<SettingsBloc, SettingsState>(
                    cubit: _bloc,
                    buildWhen: (a, b) =>
                        a.validateCertificates != b.validateCertificates,
                    builder: (context, state) {
                      return _BoolInputOption(
                        title: i18n.validateCertificates,
                        value: state.validateCertificates,
                        onChanged: (value) {
                          _bloc
                              .add(SettingsEdited(validateCertificates: value));
                        },
                      );
                    },
                  ),
                  // User-Agent.
                  BlocBuilder<SettingsBloc, SettingsState>(
                    cubit: _bloc,
                    buildWhen: (a, b) => a.userAgent != b.userAgent,
                    builder: (context, state) {
                      return _ClickInputOption(
                        title: i18n.userAgent,
                        subtitle: state.userAgent,
                        onTap: () async {
                          final res = await InputTextDialog.show(
                            context,
                            state.userAgent,
                            i18n.value,
                            i18n.userAgent,
                            maxLength: null,
                          );

                          if (!res.cancelled && res.data != null) {
                            _bloc.add(SettingsEdited(userAgent: res.data));
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              // Response.
              _OptionCard(
                title: i18n.response,
                children: <Widget>[
                  // Save Response Body.
                  BlocBuilder<SettingsBloc, SettingsState>(
                    cubit: _bloc,
                    buildWhen: (a, b) =>
                        a.saveResponseBody != b.saveResponseBody,
                    builder: (context, state) {
                      return _BoolInputOption(
                        title: i18n.saveResponseBody,
                        value: state.saveResponseBody,
                        onChanged: (value) {
                          _bloc.add(SettingsEdited(saveResponseBody: value));
                        },
                      );
                    },
                  ),
                  // Font size.
                  BlocBuilder<SettingsBloc, SettingsState>(
                    cubit: _bloc,
                    buildWhen: (a, b) =>
                        a.responseBodyFontSize != b.responseBodyFontSize,
                    builder: (context, state) {
                      return _DropdownOption<int>(
                        title: i18n.fontSize,
                        initialValue: state.responseBodyFontSize.toInt(),
                        items: _availableFontSizes,
                        itemBuilder: (context, index, item) {
                          return Center(
                            child: Text('$item'),
                          );
                        },
                        onChanged: (value) {
                          _bloc.add(SettingsEdited(
                            responseBodyFontSize: value.toDouble(),
                          ));
                        },
                      );
                    },
                  ),
                ],
              ),
              // Cache.
              _OptionCard(
                title: i18n.cache,
                children: <Widget>[
                  // Enable.
                  BlocBuilder<SettingsBloc, SettingsState>(
                    cubit: _bloc,
                    buildWhen: (a, b) => a.cacheEnabled != b.cacheEnabled,
                    builder: (context, state) {
                      return _BoolInputOption(
                        title: i18n.enabled,
                        value: state.cacheEnabled,
                        onChanged: (value) async {
                          if (value &&
                              !await handlePermission(Permission.storage)) {
                            return;
                          }

                          _bloc.add(SettingsEdited(cacheEnabled: value));
                        },
                      );
                    },
                  ),
                  // Max Size.
                  BlocBuilder<SettingsBloc, SettingsState>(
                    cubit: _bloc,
                    buildWhen: (a, b) => a.cacheMaxSize != b.cacheMaxSize,
                    builder: (context, state) {
                      return _DropdownOption<int>(
                        title: '${i18n.maxSize} (MiB)',
                        initialValue: state.cacheMaxSize,
                        items: _availableCacheMaxSizes,
                        itemBuilder: (context, index, item) {
                          return Center(
                            child: Text('$item'),
                          );
                        },
                        onChanged: (value) {
                          _bloc.add(SettingsEdited(cacheMaxSize: value));
                        },
                      );
                    },
                  ),
                  // Clear.
                  BlocBuilder<SettingsBloc, SettingsState>(
                    cubit: _bloc,
                    buildWhen: (a, b) => a.cacheSize != b.cacheSize,
                    builder: (context, state) {
                      return _ButtonInputOption(
                        text: '${i18n.clear}: ${state.cacheSize} B',
                        onPressed: () {
                          _bloc.add(CacheCleared());
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
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _OptionCard({
    Key key,
    @required this.title,
    @required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: <Widget>[
            // Title.
            Text(title.toUpperCase()),
            ...children,
          ],
        ),
      ),
    );
  }
}

abstract class _InputOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _InputOption({
    Key key,
    @required this.title,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  Widget buildOption(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: buildOption(context),
      onTap: onTap,
    );
  }
}

class _ClickInputOption extends _InputOption {
  const _ClickInputOption({
    String title,
    String subtitle,
    VoidCallback onTap,
  }) : super(title: title, subtitle: subtitle, onTap: onTap);

  @override
  Widget buildOption(BuildContext context) {
    return null;
  }
}

class _BoolInputOption extends _InputOption {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BoolInputOption({
    String title,
    String subtitle,
    @required this.value,
    this.onChanged,
  }) : super(title: title, subtitle: subtitle);

  @override
  Widget buildOption(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
    );
  }
}

class _TextInputOption extends _InputOption {
  final String value;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;

  const _TextInputOption({
    String title,
    String subtitle,
    @required this.value,
    this.onChanged,
    this.keyboardType,
  }) : super(title: title, subtitle: subtitle);

  @override
  Widget buildOption(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInputDialog(context),
      child: Container(
        width: 50,
        child: Text(
          value ?? '',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showInputDialog(BuildContext context) async {
    final res = await InputTextDialog.show(
      context,
      value,
      '',
      title,
      keyboardType: keyboardType,
    );

    if (!res.cancelled && res.data != null && res.data.isNotEmpty) {
      onChanged?.call(res.data);
    }
  }
}

class _DropdownOption<T> extends _InputOption {
  final T initialValue;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  const _DropdownOption({
    String title,
    String subtitle,
    @required this.initialValue,
    this.onChanged,
    @required this.items,
    @required this.itemBuilder,
  }) : super(title: title, subtitle: subtitle);

  @override
  Widget buildOption(BuildContext context) {
    return Container(
      width: 50,
      child: ContextMenuButton<T>(
        initialValue: initialValue,
        items: items,
        itemBuilder: itemBuilder,
        onChanged: onChanged,
      ),
    );
  }
}

class _ButtonInputOption extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _ButtonInputOption({
    @required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ActionButton(
        onPressed: onPressed,
        text: text,
      ),
    );
  }
}
