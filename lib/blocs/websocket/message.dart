import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final bool sent;
  final int timestamp;
  final String data;

  const Message({
    this.sent,
    this.timestamp,
    this.data,
  });

  @override
  List get props => [sent, timestamp, data];
}
