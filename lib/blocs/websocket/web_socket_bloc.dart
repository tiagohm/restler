import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:restio/restio.dart';
import 'package:restler/blocs/constants.dart';
import 'package:restler/blocs/websocket/message.dart';
import 'package:restler/blocs/websocket/web_socket_event.dart';
import 'package:restler/blocs/websocket/web_socket_state.dart';
import 'package:restler/data/entities/header_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:restler/messager.dart';
import 'package:rxdart/rxdart.dart';

final client = Restio();

class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  final Messager _messager = kiwi();

  WebSocketBloc() : super(const WebSocketState());

  @override
  Stream<Transition<WebSocketEvent, WebSocketState>> transformTransitions(
    Stream<Transition<WebSocketEvent, WebSocketState>> transitions,
  ) {
    final debounceStream = transitions
        .where((event) => event.event is SearchTextChanged)
        .debounceTime(const Duration(milliseconds: searchTextDebounceTime));
    final nonDebounceStream =
        transitions.where((event) => event.event is! SearchTextChanged);

    return Rx.merge([debounceStream, nonDebounceStream]);
  }

  @override
  Stream<WebSocketState> mapEventToState(WebSocketEvent event) async* {
    if (event is SearchToggled) {
      yield* _mapSearchToggledToState(event);
    } else if (event is SearchTextChanged) {
      yield* _mapSearchTextChangedToState(event);
    } else if (event is Connected) {
      yield* _mapConnectedToState(event);
    } else if (event is Disconnected) {
      yield* _mapDisconnectedToState(event);
    } else if (event is BodyChanged) {
      yield* _mapBodyChangedToState(event);
    } else if (event is UriChanged) {
      yield* _mapUriChangedToState(event);
    } else if (event is HeaderAdded) {
      yield* _mapHeaderAddedToState();
    } else if (event is HeaderEdited) {
      yield* _mapHeaderEditedToState(event);
    } else if (event is HeaderDuplicated) {
      yield* _mapHeaderDuplicatedToState(event);
    } else if (event is HeaderDeleted) {
      yield* _mapHeaderDeletedToState(event);
    } else if (event is MessageSent) {
      yield* _mapMessageSentToState(event);
    } else if (event is MessageReceived) {
      yield* _mapMessageReceivedToState(event);
    } else if (event is MessageCleared) {
      yield* _mapMessageClearedToState(event);
    }
  }

  Stream<WebSocketState> _mapSearchToggledToState(SearchToggled event) async* {
    yield state.copyWith(search: !state.search);
  }

  Stream<WebSocketState> _mapSearchTextChangedToState(
      SearchTextChanged event) async* {
    final messages = [
      if (event.text.isEmpty)
        ...state.messages
      else
        for (final item in state.messages)
          if (item.data.contains(event.text)) item,
    ];

    yield state.copyWith(
      searchText: event.text,
      filteredMessages: messages,
    );
  }

  Stream<WebSocketState> _mapConnectedToState(Connected event) async* {
    // Já está conectado.
    if (state.connected) {
      return;
    }

    try {
      final request = Request(
        uri: RequestUri.parse(state.uri),
        headers: _obtainHeaders(state.headers),
      );

      final ws = client.newWebSocket(request);

      _messager.show((i18n) => i18n.connecting, type: MessagerType.info);

      final connection = await ws.open();

      connection.stream.listen((data) {
        if (data is String) {
          final message = Message(
            sent: false,
            timestamp: currentMillis(),
            data: data,
          );

          add(MessageReceived(message));
        } else {
          _messager.show(
            (i18n) => i18n.binaryDataTypeIsNotSupported,
            type: MessagerType.error,
          );
        }
      });

      yield state.copyWith(
        connected: true,
        connection: connection,
        messages: const [],
        filteredMessages: const [],
      );

      _messager.show((i18n) => i18n.connected, type: MessagerType.success);
    } on WebSocketException catch (e) {
      final message = e.message;

      _messager.show(
        (i18n) => message,
        type: MessagerType.error,
      );
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

  static Headers _obtainHeaders(List<HeaderEntity> data) {
    final headers = HeadersBuilder();

    for (final item in data) {
      if (item.isValid) {
        headers.add(item.name, item.value);
      }
    }

    return headers.build();
  }

  Stream<WebSocketState> _mapDisconnectedToState(Disconnected event) async* {
    try {
      await state.connection.close(3000, 'Disconnected');
      await state.connection.done;
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
    } finally {
      yield state.copyWith(connected: false);
      _messager.show((i18n) => i18n.disconnected, type: MessagerType.error);
    }
  }

  Stream<WebSocketState> _mapBodyChangedToState(BodyChanged event) async* {
    yield state.copyWith(body: event.text);
  }

  Stream<WebSocketState> _mapUriChangedToState(UriChanged event) async* {
    yield state.copyWith(uri: event.uri);
  }

  Stream<WebSocketState> _mapHeaderAddedToState() async* {
    yield state.copyWith(
      headers: [
        ...state.headers,
        HeaderEntity(uid: generateUuid()),
      ],
    );
  }

  Stream<WebSocketState> _mapHeaderEditedToState(
    HeaderEdited event,
  ) async* {
    final items = List.of(state.headers);

    final index = items.indexWhere((item) => item.uid == event.header.uid);

    if (index < 0) {
      return;
    }

    items[index] = event.header;

    yield state.copyWith(headers: items);
  }

  Stream<WebSocketState> _mapHeaderDuplicatedToState(
    HeaderDuplicated event,
  ) async* {
    final items = List.of(state.headers);

    final index = items.indexWhere((item) => item.uid == event.header.uid);

    if (index < 0) {
      return;
    }

    items.insert(index, items[index].copyWith(uid: generateUuid()));

    yield state.copyWith(headers: items);
  }

  Stream<WebSocketState> _mapHeaderDeletedToState(
    HeaderDeleted event,
  ) async* {
    final items = List.of(state.headers);

    final index = items.indexWhere((item) => item.uid == event.header.uid);

    if (index < 0) {
      return;
    }

    items.removeAt(index);

    yield state.copyWith(headers: items);
  }

  Stream<WebSocketState> _mapMessageSentToState(
    MessageSent event,
  ) async* {
    if (state.body.isNotEmpty &&
        state.connected &&
        state.connection.readyState == 1) {
      state.connection.addString(state.body);

      final items = List.of(state.messages);
      final message = Message(
        sent: true,
        timestamp: currentMillis(),
        data: state.body,
      );
      items.add(message);
      yield state.copyWith(messages: items, filteredMessages: items);
    }
  }

  Stream<WebSocketState> _mapMessageReceivedToState(
    MessageReceived event,
  ) async* {
    final items = List.of(state.messages);
    items.add(event.message);
    yield state.copyWith(messages: items, filteredMessages: items);
  }

  Stream<WebSocketState> _mapMessageClearedToState(
    MessageCleared event,
  ) async* {
    yield state.copyWith(
      messages: const [],
      filteredMessages: const [],
    );
  }
}
