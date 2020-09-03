import 'package:restler/data/entities/variable_entity.dart';

abstract class VariableEvent {}

class VariableFetched extends VariableEvent {}

class SearchTextChanged extends VariableEvent {
  final String text;

  SearchTextChanged(this.text);
}

class SearchToggled extends VariableEvent {}

class VariableCreated extends VariableEvent {
  final String name;
  final String value;
  final bool secret;

  // ignore: avoid_positional_boolean_parameters
  VariableCreated(this.name, this.value, this.secret);
}

class VariableEdited extends VariableEvent {
  final VariableEntity variable;

  VariableEdited(this.variable);
}

class VariableDuplicated extends VariableEvent {
  final VariableEntity variable;

  VariableDuplicated(this.variable);
}

class VariableDeleted extends VariableEvent {
  final VariableEntity variable;

  VariableDeleted(this.variable);
}

class VariableCleared extends VariableEvent {}
