import 'package:bloc/bloc.dart';
import 'package:restler/blocs/constants.dart';
import 'package:restler/blocs/variable/variable_event.dart';
import 'package:restler/blocs/variable/variable_state.dart';
import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/variable_entity.dart';
import 'package:restler/data/repositories/variable_repository.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:rxdart/rxdart.dart';

class VariableBloc extends Bloc<VariableEvent, VariableState> {
  final EnvironmentEntity environment;
  final _variableRepository = kiwi<VariableRepository>();

  VariableBloc(this.environment) : super(const VariableState());

  @override
  Stream<Transition<VariableEvent, VariableState>> transformTransitions(
    Stream<Transition<VariableEvent, VariableState>> transitions,
  ) {
    final debounceStream = transitions
        .where((event) => event.event is SearchTextChanged)
        .debounceTime(const Duration(milliseconds: searchTextDebounceTime));
    final nonDebounceStream =
        transitions.where((event) => event.event is! SearchTextChanged);

    return Rx.merge([debounceStream, nonDebounceStream]);
  }

  @override
  Stream<VariableState> mapEventToState(VariableEvent event) async* {
    if (event is SearchTextChanged) {
      yield* _mapSearchTextChangedToState(event);
    } else if (event is SearchToggled) {
      yield* _mapSearchToggledToState(event);
    } else if (event is VariableFetched) {
      yield* _mapVariableFetchedToState(event);
    } else if (event is VariableCreated) {
      yield* _mapVariableCreatedToState(event);
    } else if (event is VariableEdited) {
      yield* _mapVariableEditedToState(event);
    } else if (event is VariableDuplicated) {
      yield* _mapVariableDuplicatedToState(event);
    } else if (event is VariableDeleted) {
      yield* _mapVariableDeletedToState(event);
    } else if (event is VariableCleared) {
      yield* _mapVariableClearedToState(event);
    }
  }

  Stream<VariableState> _mapSearchTextChangedToState(
    SearchTextChanged event,
  ) async* {
    final data =
        await _variableRepository.search(environment, text: event.text);

    yield state.copyWith(
      data: data,
      searchText: event.text,
    );
  }

  Stream<VariableState> _mapSearchToggledToState(SearchToggled event) async* {
    yield state.copyWith(search: !state.search);
  }

  Stream<VariableState> _mapVariableFetchedToState(
    VariableFetched event,
  ) async* {
    final data =
        await _variableRepository.search(environment, text: state.searchText);

    yield state.copyWith(data: data);
  }

  Stream<VariableState> _mapVariableCreatedToState(
    VariableCreated event,
  ) async* {
    final variable = VariableEntity(
      uid: generateUuid(),
      name: event.name,
      value: event.value,
      workspace: environment.workspace,
      environment: environment,
      secret: event.secret,
    );

    await _variableRepository.insert(variable);

    add(VariableFetched());
  }

  Stream<VariableState> _mapVariableEditedToState(
    VariableEdited event,
  ) async* {
    await _variableRepository.update(event.variable);
    add(VariableFetched());
  }

  Stream<VariableState> _mapVariableDuplicatedToState(
    VariableDuplicated event,
  ) async* {
    final variable = event.variable.copyWith(
      uid: generateUuid(),
      enabled: true,
    );

    await _variableRepository.insert(variable);

    add(VariableFetched());
  }

  Stream<VariableState> _mapVariableDeletedToState(
    VariableDeleted event,
  ) async* {
    await _variableRepository.delete(event.variable);
    add(VariableFetched());
  }

  Stream<VariableState> _mapVariableClearedToState(
    VariableCleared event,
  ) async* {
    if (await _variableRepository.clearByEnvironment(environment)) {
      add(VariableFetched());
    }
  }
}
