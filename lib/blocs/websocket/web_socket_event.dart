import 'package:restler/blocs/websocket/message.dart';
import 'package:restler/data/entities/header_entity.dart';

abstract class WebSocketEvent {}

class SearchToggled extends WebSocketEvent {}

class SearchTextChanged extends WebSocketEvent {
  final String text;

  SearchTextChanged(this.text);
}

class Connected extends WebSocketEvent {}

class Disconnected extends WebSocketEvent {}

class UriChanged extends WebSocketEvent {
  final String uri;

  UriChanged(this.uri);
}

class BodyChanged extends WebSocketEvent {
  final String text;

  BodyChanged(this.text);
}

class HeaderAdded extends WebSocketEvent {}

class HeaderEdited extends WebSocketEvent {
  final HeaderEntity header;

  HeaderEdited(this.header);
}

class HeaderDeleted extends WebSocketEvent {
  final HeaderEntity header;

  HeaderDeleted(this.header);
}

class HeaderDuplicated extends WebSocketEvent {
  final HeaderEntity header;

  HeaderDuplicated(this.header);
}

class MessageSent extends WebSocketEvent {}

class MessageReceived extends WebSocketEvent {
  final Message message;

  MessageReceived(this.message);
}

class MessageCleared extends WebSocketEvent {}
