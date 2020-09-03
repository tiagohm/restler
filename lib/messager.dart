import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:restler/i18n.dart';

enum MessagerType { none, error, warning, info, success }

class MessagerData {
  final String Function(I18n i18n) message;
  final String title;
  final bool isDismissible;
  final bool top;
  final String actionText;
  final MessagerType type;
  final VoidCallback onYes;
  final VoidCallback onCancel;

  const MessagerData({
    this.message,
    this.title,
    this.isDismissible = false,
    this.top = false,
    this.actionText,
    this.type,
    this.onYes,
    this.onCancel,
  });
}

class _MessagerSubscriptionItem extends Equatable {
  final State state;
  final StreamSubscription subscription;

  const _MessagerSubscriptionItem(this.state, this.subscription);

  @override
  List<Object> get props => [state, subscription];
}

class Messager {
  final EventBus eventBus;
  final _subscriptions = ListQueue<_MessagerSubscriptionItem>();

  Messager(this.eventBus);

  void registerOnState(State s) {
    unregisterOnState(s);

    print('Registrando Messager em ${s.runtimeType}');

    // ignore: cancel_subscriptions
    StreamSubscription ss;
    ss = eventBus.on<MessagerData>().listen((event) {
      if (_subscriptions.isEmpty) {
        print('Ops! Não há inscrições');
        return;
      }

      final first = _subscriptions.first;

      if (first.subscription == ss && first.state.mounted) {
        handleMessagerData(first.state.context, event);
      }
    });

    _subscriptions.addFirst(_MessagerSubscriptionItem(s, ss));
  }

  void unregisterOnState(State s) {
    if (_subscriptions.isEmpty) {
      return;
    }

    final first = _subscriptions.first;

    if (first.state == s) {
      print('Desregistrando Messager em ${s.runtimeType}');
      first.subscription.cancel();
      _subscriptions.removeFirst();
    }
  }

  void show(
    String Function(I18n i18n) message, {
    String title,
    bool isDismissible = false,
    bool top = false,
    String actionText,
    MessagerType type,
    VoidCallback onYes,
    VoidCallback onCancel,
  }) {
    eventBus.fire(MessagerData(
      message: message,
      title: title,
      isDismissible: isDismissible,
      top: top,
      actionText: actionText,
      type: type,
      onYes: onYes,
      onCancel: onCancel,
    ));
  }

  static void handleMessagerData(
    BuildContext context,
    MessagerData data,
  ) async {
    if (context == null) {
      print("Can't show snackbar because context is null");
      return;
    }
    final text = data.message(I18n.of(context));

    if (text == null || text.isEmpty) {
      print("Can't show snackbar because text is empty");
      return;
    }

    print('Exibindo SnackBar em ${context.widget.runtimeType}: $text');

    _showFlushbar(
      context,
      title: data.title,
      message: text,
      isDismissible: data.isDismissible,
      top: data.top,
      actionText: data.actionText,
      icon: _obtainIcon(data.type),
    ).then((value) {
      if (value == true) {
        data.onYes?.call();
      } else {
        data.onCancel?.call();
      }
    });
  }

  static Icon _obtainIcon(MessagerType type) {
    if (type == null || type == MessagerType.none) {
      return null;
    }

    final color = _obtainBackgroundColor(type);

    switch (type) {
      case MessagerType.error:
        return Icon(Icons.error, color: color);
      case MessagerType.warning:
        return Icon(Icons.warning, color: color);
      case MessagerType.info:
        return Icon(Icons.info, color: color);
      case MessagerType.success:
        return Icon(Icons.check, color: color);
      default:
        return null;
    }
  }

  static Color _obtainBackgroundColor(MessagerType type) {
    if (type == null || type == MessagerType.none) {
      return null;
    }

    switch (type) {
      case MessagerType.error:
        return Colors.red;
      case MessagerType.warning:
        return Colors.orange;
      case MessagerType.info:
        return Colors.blue;
      case MessagerType.success:
        return Colors.green;
      default:
        return null;
    }
  }

  static Future<bool> _showFlushbar(
    BuildContext context, {
    String title,
    @required String message,
    bool isDismissible = true,
    bool top = false,
    String actionText,
    Icon icon,
    Color backgroundColor,
  }) async {
    Flushbar<bool> flush;

    flush = Flushbar<bool>(
      title: title,
      message: message,
      duration: const Duration(seconds: 5),
      isDismissible: isDismissible,
      icon: icon,
      mainButton: actionText == null
          ? null
          : FlatButton(
              onPressed: () {
                flush?.dismiss(true);
              },
              child: Text(
                actionText.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).indicatorColor,
                ),
              ),
            ),
      flushbarPosition: top ? FlushbarPosition.TOP : FlushbarPosition.BOTTOM,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
    );

    final res = await flush.show(context);
    return res ?? false;
  }
}
