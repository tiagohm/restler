import 'package:bloc/bloc.dart';
import 'package:restio/restio.dart' as restio;
import 'package:restler/blocs/constants.dart';
import 'package:restler/blocs/sse/message.dart';
import 'package:restler/blocs/sse/sse_event.dart';
import 'package:restler/blocs/sse/sse_state.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:restler/messager.dart';
import 'package:rxdart/rxdart.dart';

final client = restio.Restio();

class SseBloc extends Bloc<SseEvent, SseState> {
  final Messager _messager = kiwi();

  SseBloc() : super(const SseState());

  @override
  Stream<Transition<SseEvent, SseState>> transformTransitions(
    Stream<Transition<SseEvent, SseState>> transitions,
  ) {
    final debounceStream = transitions
        .where((event) => event.event is SearchTextChanged)
        .debounceTime(const Duration(milliseconds: searchTextDebounceTime));
    final nonDebounceStream =
        transitions.where((event) => event.event is! SearchTextChanged);

    return Rx.merge([debounceStream, nonDebounceStream]);
  }

  @override
  Stream<SseState> mapEventToState(SseEvent event) async* {
    if (event is SearchToggled) {
      yield* _mapSearchToggledToState(event);
    } else if (event is SearchTextChanged) {
      yield* _mapSearchTextChangedToState(event);
    } else if (event is Connected) {
      yield* _mapConnectedToState(event);
    } else if (event is Disconnected) {
      yield* _mapDisconnectedToState(event);
    } else if (event is UriChanged) {
      yield* _mapUriChangedToState(event);
    } else if (event is MessageReceived) {
      yield* _mapMessageReceivedToState(event);
    } else if (event is MessageCleared) {
      yield* _mapMessageClearedToState(event);
    }
  }

  Stream<SseState> _mapSearchToggledToState(SearchToggled event) async* {
    yield state.copyWith(search: !state.search);
  }

  Stream<SseState> _mapSearchTextChangedToState(
    SearchTextChanged event,
  ) async* {
    final messages = [
      if (event.text.isEmpty)
        ...state.messages
      else
        for (final item in state.messages)
          if (item.data.event.contains(event.text) ||
              item.data.data.contains(event.text))
            item,
    ];

    yield state.copyWith(
      searchText: event.text,
      filteredMessages: messages,
    );
  }

  Stream<SseState> _mapConnectedToState(Connected event) async* {
    // Já está conectado.
    if (state.connected) {
      return;
    }

    try {
      final request = restio.Request(uri: restio.RequestUri.parse(state.uri));

      final ws = client.newSse(request);

      _messager.show((i18n) => i18n.connecting, type: MessagerType.info);

      final connection = await ws.open();

      connection.stream.listen((event) {
        final message = Message(
          timestamp: currentMillis(),
          data: event,
        );

        add(MessageReceived(message));
      }, onError: (e, stackTrace) {
        print(e);
        print(stackTrace);
        add(Disconnected());
      }, onDone: () {
        add(Disconnected());
      });

      yield state.copyWith(
        connected: true,
        connection: connection,
        messages: const [],
        filteredMessages: const [],
      );

      _messager.show((i18n) => i18n.connected, type: MessagerType.success);
    } on FormatException catch (e) {
      final message = e.message;

      _messager.show(
        (i18n) => message,
        type: MessagerType.error,
      );
    } catch (e) {
      _messager.show(
        (i18n) => e.toString(),
        type: MessagerType.error,
      );
    }
  }

  Stream<SseState> _mapDisconnectedToState(Disconnected event) async* {
    try {
      await state.connection.close();
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
    } finally {
      yield state.copyWith(connected: false);
      _messager.show((i18n) => i18n.disconnected, type: MessagerType.error);
    }
  }

  Stream<SseState> _mapUriChangedToState(UriChanged event) async* {
    yield state.copyWith(uri: event.uri);
  }

  Stream<SseState> _mapMessageReceivedToState(
    MessageReceived event,
  ) async* {
    final items = List.of(state.messages);
    items.add(event.message);
    yield state.copyWith(messages: items, filteredMessages: items);
  }

  Stream<SseState> _mapMessageClearedToState(
    MessageCleared event,
  ) async* {
    yield state.copyWith(
      messages: const [],
      filteredMessages: const [],
    );
  }
}
