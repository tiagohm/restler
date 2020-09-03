import 'package:equatable/equatable.dart';
import 'package:restio/restio.dart' as restio;

class Message extends Equatable {
  final int timestamp;
  final restio.SseEvent data;

  const Message({
    this.timestamp,
    this.data,
  });

  @override
  List get props => [timestamp, data];
}
