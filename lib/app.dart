import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:restler/blocs/settings/bloc.dart';
import 'package:restler/i18n.dart';
import 'package:restler/inject.dart';
import 'package:restler/router.dart';
import 'package:restler/theme.dart';

class App extends StatefulWidget {
  const App({
    Key key,
  }) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final SettingsBloc _settingsBloc = kiwi();

  @override
  void dispose() {
    _settingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const i18n = I18n.delegate;

    return BlocBuilder<SettingsBloc, SettingsState>(
      key: const Key('app'),
      cubit: _settingsBloc,
      buildWhen: (a, b) => a.darkTheme != b.darkTheme,
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: state.darkTheme ? darkTheme() : lightTheme(),
          localizationsDelegates: [
            i18n,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: i18n.supportedLocales,
          localeResolutionCallback:
              i18n.resolution(fallback: const Locale('en', 'US')),
          onGenerateRoute: generateRoutes,
          navigatorKey: navigatorKey,
        );
      },
    );
  }
}
