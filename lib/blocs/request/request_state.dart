import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:restio/restio.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/response_entity.dart';

@immutable
class RequestState extends Equatable {
  final RequestEntity request;
  final ResponseEntity response;
  final bool sending;
  final Call call;

  const RequestState({
    this.request = RequestEntity.empty,
    this.response = ResponseEntity.empty,
    this.sending = false,
    this.call,
  });

  RequestState copyWith({
    RequestEntity request,
    ResponseEntity response,
    bool sending,
    Call call,
  }) {
    return RequestState(
      request: request ?? this.request,
      response: response ?? this.response,
      sending: sending ?? this.sending,
      call: call ?? this.call,
    );
  }

  @override
  List get props => [request, response, sending];
}
