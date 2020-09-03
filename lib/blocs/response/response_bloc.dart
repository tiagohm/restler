import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/scheduler.dart';
import 'package:path/path.dart' as p;
import 'package:restler/blocs/response/response_event.dart';
import 'package:restler/blocs/response/response_state.dart';
import 'package:restler/data/entities/response_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:restler/messager.dart';

class ResponseBloc extends Bloc<ResponseEvent, ResponseState> {
  final Messager _messager = kiwi();

  ResponseBloc() : super(const ResponseState());

  @override
  Stream<ResponseState> mapEventToState(ResponseEvent event) async* {
    if (event is ResponseLoaded) {
      yield* _mapResponseLoadedToState(event);
    } else if (event is ResponseModeChanged) {
      yield* _mapResponseModeChangedToState(event);
    } else if (event is ResponseBodyCopied) {
      yield* _mapResponseBodyCopiedToState(event);
    } else if (event is ResponseBodySavedAsFile) {
      yield* _mapResponseBodySavedAsFileToState(event);
    }
  }

  Stream<ResponseState> _mapResponseLoadedToState(ResponseLoaded event) async* {
    final encoding = event.response.contentType?.encoding;
    var text = '';
    var prettyText = '';
    ResponseMode mode;
    var invalidJson = false;

    if (event.response.data.isNotEmpty) {
      text = await SchedulerBinding.instance.scheduleTask(
        () {
          try {
            return encoding.decode(event.response.data);
          } catch (e) {
            return String.fromCharCodes(event.response.data);
          }
        },
        Priority.touch,
      );

      if (event.response.isJson) {
        await SchedulerBinding.instance.scheduleTask<void>(
          () {
            try {
              final o = json.decoder.convert(text);
              prettyText = const JsonEncoder.withIndent('  ').convert(o);
            } on FormatException {
              invalidJson = true;
              prettyText = '';
              mode = ResponseMode.raw;

              _messager.show(
                (i18n) => i18n.invalidFormat,
                type: MessagerType.error,
              );
            }
          },
          Priority.touch,
        );
      } else {
        prettyText = text;
      }
    }

    yield ResponseState(
      response: event.response,
      text: text,
      prettyText: prettyText,
      mode: mode ?? _obtainResponseMode(event.response),
      invalid: invalidJson,
    );
  }

  Stream<ResponseState> _mapResponseModeChangedToState(
    ResponseModeChanged event,
  ) async* {
    yield state.copyWith(mode: event.mode);
  }

  ResponseMode _obtainResponseMode(ResponseEntity response) {
    if (response.data.isEmpty) {
      return ResponseMode.raw;
    }
    if (response.isVisual) {
      return ResponseMode.visual;
    }
    if (response.isHighlighted) {
      return ResponseMode.pretty;
    }
    return ResponseMode.raw;
  }

  Stream<ResponseState> _mapResponseBodyCopiedToState(
    ResponseBodyCopied event,
  ) async* {
    await copyToClipboard(state.prettyText);

    _messager.show((i18n) => i18n.copiedToClipboard);
  }

  Stream<ResponseState> _mapResponseBodySavedAsFileToState(
    ResponseBodySavedAsFile event,
  ) async* {
    final path = p.join(event.path, event.name);
    final file = File(path);

    if (state.mode == ResponseMode.pretty) {
      await file.writeAsString(state.prettyText);
    } else if (state.mode == ResponseMode.raw) {
      await file.writeAsString(state.text);
    } else {
      await file.writeAsBytes(state.response.data);
    }

    _messager.show((i18n) => i18n.fileSavedAt(path));
  }
}
