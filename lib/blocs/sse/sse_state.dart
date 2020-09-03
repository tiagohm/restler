import 'package:equatable/equatable.dart';
import 'package:restio/restio.dart';
import 'package:restler/blocs/sse/message.dart';

class SseState extends Equatable {
  final bool search;
  final String searchText;
  final bool connected;
  final String uri;
  final List<Message> messages;
  final List<Message> filteredMessages;
  final SseConnection connection;

  const SseState({
    this.search = false,
    this.searchText = '',
    this.connected = false,
    this.uri = 'https://express-eventsource.herokuapp.com/events',
    this.messages = const [],
    this.filteredMessages = const [],
    this.connection,
  });

  SseState copyWith({
    bool search,
    String searchText,
    bool connected,
    String uri,
    List<Message> messages,
    List<Message> filteredMessages,
    SseConnection connection,
  }) {
    return SseState(
      search: search ?? this.search,
      searchText: searchText ?? this.searchText,
      connected: connected ?? this.connected,
      uri: uri ?? this.uri,
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
        uri,
        messages,
        filteredMessages,
      ];
}
