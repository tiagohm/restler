import 'package:restler/blocs/response/response_state.dart';
import 'package:restler/data/entities/response_entity.dart';

abstract class ResponseEvent {}

class ResponseLoaded extends ResponseEvent {
  final ResponseEntity response;

  ResponseLoaded(this.response);
}

class ResponseModeChanged extends ResponseEvent {
  final ResponseMode mode;

  ResponseModeChanged(this.mode);
}

class ResponseBodyCopied extends ResponseEvent {}

class ResponseBodySavedAsFile extends ResponseEvent {
  final String name;
  final String path;

  ResponseBodySavedAsFile(this.name, this.path);
}
