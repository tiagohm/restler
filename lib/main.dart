import 'package:bloc/bloc.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/widgets.dart';
import 'package:restler/app.dart';
import 'package:restler/inject.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initInject();

  Bloc.observer = _BlocObserver();

  runApp(const App());
}

class _BlocObserver implements BlocObserver {
  final _eventBus = kiwi<EventBus>();

  @override
  void onEvent(
    Bloc bloc,
    Object event,
  ) {
    print('event: ${bloc.runtimeType}(${event.runtimeType})');
    _eventBus.fire(event);
  }

  @override
  void onTransition(
    Bloc bloc,
    Transition transition,
  ) {
    print('transition: ${bloc.runtimeType}(${transition.event.runtimeType})');
    _eventBus.fire(transition);
  }

  @override
  void onChange(
    Cubit cubit,
    Change change,
  ) {}

  @override
  void onError(
    Cubit cubit,
    Object error,
    StackTrace stackTrace,
  ) {
    print('error: $error');
    print(stackTrace);
  }

  @override
  void onClose(Cubit cubit) {}

  @override
  void onCreate(Cubit cubit) {}
}
