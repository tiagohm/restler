import 'package:equatable/equatable.dart';
import 'package:restio/restio.dart';
import 'package:restler/blocs/websocket/message.dart';
import 'package:restler/data/entities/header_entity.dart';

class WebSocketState extends Equatable {
  final bool search;
  final String searchText;
  final bool connected;
  final String body;
  final String uri;
  final List<String> protocols;
  final List<HeaderEntity> headers;
  final List<Message> messages;
  final List<Message> filteredMessages;
  final WebSocketConnection connection;

  const WebSocketState({
    this.search = false,
    this.searchText = '',
    this.connected = false,
    this.body = '',
    this.uri = 'wss://echo.websocket.org',
    this.protocols = const [],
    this.headers = const [],
    this.messages = const [],
    this.filteredMessages = const [],
    this.connection,
  });

  WebSocketState copyWith({
    bool search,
    String searchText,
    bool connected,
    String body,
    String uri,
    List<String> protocols,
    List<HeaderEntity> headers,
    List<Message> messages,
    List<Message> filteredMessages,
    WebSocketConnection connection,
  }) {
    return WebSocketState(
      search: search ?? this.search,
      searchText: searchText ?? this.searchText,
      connected: connected ?? this.connected,
      body: body ?? this.body,
      uri: uri ?? this.uri,
      protocols: protocols ?? this.protocols,
      headers: headers ?? this.headers,
      messages: messages ?? this.messages,
      filteredMessages: filteredMessages ?? this.filteredMessages,
      connection: connection ?? this.connection,
    );
  }

  @override
  List get props => [
        search,
        searchText,
        connected,
        body,
        uri,
        protocols,
        headers,
        messages,
        filteredMessages,
      ];
}
