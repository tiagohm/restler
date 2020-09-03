import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:restler/data/entities/response_entity.dart';

enum ResponseMode { visual, pretty, raw }

@immutable
class ResponseState extends Equatable {
  final ResponseEntity response;
  final String text; // raw.
  final String prettyText;
  final ResponseMode mode;
  final bool invalid;

  const ResponseState({
    this.response = ResponseEntity.empty,
    this.text = '',
    this.prettyText = '',
    this.mode = ResponseMode.raw,
    this.invalid = false,
  });

  ResponseState copyWith({
    ResponseEntity response,
    String text,
    String prettyText,
    ResponseMode mode,
    bool invalid,
  }) {
    return ResponseState(
      response: response ?? this.response,
      text: text ?? this.text,
      prettyText: prettyText ?? this.prettyText,
      mode: mode ?? this.mode,
      invalid: invalid ?? this.invalid,
    );
  }

  @override
  List get props => [response, mode, invalid];
}
