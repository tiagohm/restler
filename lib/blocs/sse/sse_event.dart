import 'package:restler/blocs/sse/message.dart';

abstract class SseEvent {}

class SearchToggled extends SseEvent {}

class SearchTextChanged extends SseEvent {
  final String text;

  SearchTextChanged(this.text);
}

class Connected extends SseEvent {}

class Disconnected extends SseEvent {}

class UriChanged extends SseEvent {
  final String uri;

  UriChanged(this.uri);
}

class MessageReceived extends SseEvent {
  final Message message;

  MessageReceived(this.message);
}

class MessageCleared extends SseEvent {}
