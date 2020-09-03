import 'package:flutter/material.dart';
import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/ui/certificate/certificate_page.dart';
import 'package:restler/ui/collection/collection_page.dart';
import 'package:restler/ui/cookie/cookie_page.dart';
import 'package:restler/ui/dns/dns_page.dart';
import 'package:restler/ui/environment/environment_page.dart';
import 'package:restler/ui/environment/variable/variable_page.dart';
import 'package:restler/ui/history/history_page.dart';
import 'package:restler/ui/home/home_page.dart';
import 'package:restler/ui/proxy/proxy_page.dart';
import 'package:restler/ui/settings/settings_page.dart';
import 'package:restler/ui/sse/sse_page.dart';
import 'package:restler/ui/websocket/web_socket_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Route generateRoutes(RouteSettings settings) {
  switch (settings.name) {
    case '/websocket':
      const page = WebSocketPage();
      return _route(page);
    case '/sse':
      const page = SsePage();
      return _route(page);
    case '/history':
      const page = HistoryPage();
      return _route(page);
    case '/collection':
      const page = CollectionPage();
      return _route(page);
    case '/cookie':
      const page = CookiePage();
      return _route(page);
    case '/certificate':
      const page = CertificatePage();
      return _route(page);
    case '/proxy':
      const page = ProxyPage();
      return _route(page);
    case '/dns':
      const page = DnsPage();
      return _route(page);
    case '/environment':
      const page = EnvironmentPage();
      return _route(page);
    case '/variable':
      final data = settings.arguments as Map<String, dynamic>;
      final page = VariablePage(environment: data['environment']);
      return _route(page);
    case '/settings':
      const page = SettingsPage();
      return _route(page);
    default:
      const page = HomePage();
      return _route(page);
  }
}

Route _route(Widget widget) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return widget;
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<double>(begin: 0, end: 1);

      return FadeTransition(
        opacity: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

Future navigateToHome() {
  return navigatorKey.currentState.pushReplacementNamed('/');
}

Future navigateToCookie() {
  return navigatorKey.currentState.pushNamed('/cookie');
}

Future navigateToCertificate() {
  return navigatorKey.currentState.pushNamed('/certificate');
}

Future navigateToProxy() {
  return navigatorKey.currentState.pushNamed('/proxy');
}

Future navigateToDns() {
  return navigatorKey.currentState.pushNamed('/dns');
}

Future navigateToWebSocket() {
  return navigatorKey.currentState.pushNamed('/websocket');
}

Future navigateToSse() {
  return navigatorKey.currentState.pushNamed('/sse');
}

Future navigateToHistory() {
  return navigatorKey.currentState.pushNamed('/history');
}

Future navigateToCollection() {
  return navigatorKey.currentState.pushNamed('/collection');
}

Future navigateEnvironment() {
  return navigatorKey.currentState.pushNamed('/environment');
}

Future navigateVariable(EnvironmentEntity environment) {
  return navigatorKey.currentState.pushNamed(
    '/variable',
    arguments: {
      'environment': environment,
    },
  );
}

Future navigateToSettings() {
  return navigatorKey.currentState.pushNamed('/settings');
}
