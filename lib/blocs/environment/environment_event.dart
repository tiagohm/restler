import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';

abstract class EnvironmentEvent {}

class EnvironmentFetched extends EnvironmentEvent {}

class SearchTextChanged extends EnvironmentEvent {
  final String text;

  SearchTextChanged(this.text);
}

class SearchToggled extends EnvironmentEvent {}

class EnvironmentCreated extends EnvironmentEvent {
  final String name;

  EnvironmentCreated(this.name);
}

class EnvironmentEdited extends EnvironmentEvent {
  final EnvironmentEntity environment;

  EnvironmentEdited(this.environment);
}

class EnvironmentDuplicated extends EnvironmentEvent {
  final EnvironmentEntity environment;

  EnvironmentDuplicated(this.environment);
}

class EnvironmentMoved extends EnvironmentEvent {
  final EnvironmentEntity environment;
  final WorkspaceEntity workspace;

  EnvironmentMoved(this.environment, this.workspace);
}

class EnvironmentCopied extends EnvironmentEvent {
  final EnvironmentEntity environment;
  final String name;
  final WorkspaceEntity workspace;

  EnvironmentCopied(this.environment, this.name, this.workspace);
}

class EnvironmentDeleted extends EnvironmentEvent {
  final EnvironmentEntity environment;

  EnvironmentDeleted(this.environment);
}

class EnvironmentCleared extends EnvironmentEvent {}
