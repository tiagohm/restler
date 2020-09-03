import 'package:bloc/bloc.dart';
import 'package:restler/blocs/constants.dart';
import 'package:restler/blocs/environment/environment_event.dart';
import 'package:restler/blocs/environment/environment_state.dart';
import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/repositories/environment_repository.dart';
import 'package:restler/data/repositories/variable_repository.dart';
import 'package:restler/data/repositories/workspace_repository.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:rxdart/rxdart.dart';

class EnvironmentBloc extends Bloc<EnvironmentEvent, EnvironmentState> {
  final _environmentRepository = kiwi<EnvironmentRepository>();
  final _workspaceRepository = kiwi<WorkspaceRepository>();
  final _variableRepository = kiwi<VariableRepository>();

  EnvironmentBloc() : super(const EnvironmentState());

  @override
  Stream<Transition<EnvironmentEvent, EnvironmentState>> transformTransitions(
    Stream<Transition<EnvironmentEvent, EnvironmentState>> transitions,
  ) {
    final debounceStream = transitions
        .where((event) => event.event is SearchTextChanged)
        .debounceTime(const Duration(milliseconds: searchTextDebounceTime));
    final nonDebounceStream =
        transitions.where((event) => event.event is! SearchTextChanged);

    return Rx.merge([debounceStream, nonDebounceStream]);
  }

  @override
  Stream<EnvironmentState> mapEventToState(EnvironmentEvent event) async* {
    if (event is SearchTextChanged) {
      yield* _mapSearchTextChangedToState(event);
    } else if (event is SearchToggled) {
      yield* _mapSearchToggledToState(event);
    } else if (event is EnvironmentFetched) {
      yield* _mapEnvironmentFetchedToState(event);
    } else if (event is EnvironmentCreated) {
      yield* _mapEnvironmentCreatedToState(event);
    } else if (event is EnvironmentEdited) {
      yield* _mapEnvironmentEditedToState(event);
    } else if (event is EnvironmentDuplicated) {
      yield* _mapEnvironmentDuplicatedToState(event);
    } else if (event is EnvironmentCopied) {
      yield* _mapEnvironmentCopiedToState(event);
    } else if (event is EnvironmentMoved) {
      yield* _mapEnvironmentMovedToState(event);
    } else if (event is EnvironmentDeleted) {
      yield* _mapEnvironmentDeletedToState(event);
    } else if (event is EnvironmentCleared) {
      yield* _mapEnvironmentClearedToState(event);
    }
  }

  Stream<EnvironmentState> _mapSearchTextChangedToState(
    SearchTextChanged event,
  ) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    final data =
        await _environmentRepository.search(workspace, text: event.text);

    yield state.copyWith(
      data: [
        EnvironmentEntity.none.copyWith(workspace: workspace),
        ...data,
      ],
      searchText: event.text,
    );
  }

  Stream<EnvironmentState> _mapSearchToggledToState(
      SearchToggled event) async* {
    yield state.copyWith(search: !state.search);
  }

  Stream<EnvironmentState> _mapEnvironmentFetchedToState(
    EnvironmentFetched event,
  ) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    final data =
        await _environmentRepository.search(workspace, text: state.searchText);

    yield state.copyWith(
      data: [
        EnvironmentEntity.none.copyWith(workspace: workspace),
        ...data,
      ],
    );
  }

  Stream<EnvironmentState> _mapEnvironmentCreatedToState(
    EnvironmentCreated event,
  ) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    final environment = EnvironmentEntity(
      uid: generateUuid(),
      name: event.name,
      workspace: workspace,
    );

    await _environmentRepository.insert(environment);

    add(EnvironmentFetched());
  }

  Stream<EnvironmentState> _mapEnvironmentEditedToState(
    EnvironmentEdited event,
  ) async* {
    await _environmentRepository.update(event.environment);
    add(EnvironmentFetched());
  }

  Stream<EnvironmentState> _mapEnvironmentDuplicatedToState(
    EnvironmentDuplicated event,
  ) async* {
    // Pega todas as variáveis do ambiente.
    final variables = await _variableRepository.all(event.environment);
    // Duplica o ambiente.
    final environment = event.environment.copyWith(
      uid: generateUuid(),
      active: false,
      enabled: true,
    );
    // Insere no banco o ambiente e suas novas variaveis.
    if (await _environmentRepository.insert(environment)) {
      for (final item in variables) {
        await _variableRepository.insert(
          item.copyWith(
            uid: generateUuid(),
            environment: environment,
          ),
        );
      }

      add(EnvironmentFetched());
    }
  }

  Stream<EnvironmentState> _mapEnvironmentCopiedToState(
    EnvironmentCopied event,
  ) async* {
    // Pega todas as variáveis do ambiente.
    final variables = await _variableRepository.all(event.environment);
    // Cria uma cópia do ambiente apontando para outro workspace.
    final environment = event.environment.copyWith(
      uid: generateUuid(),
      name: event.name,
      active: false,
      enabled: true,
      workspace: event.workspace,
    );
    // Insere no banco o ambiente e suas novas variaveis.
    if (await _environmentRepository.insert(environment)) {
      for (final item in variables) {
        await _variableRepository.insert(
          item.copyWith(
            uid: generateUuid(),
            environment: environment,
            workspace: event.workspace,
          ),
        );
      }

      add(EnvironmentFetched());
    }
  }

  Stream<EnvironmentState> _mapEnvironmentMovedToState(
    EnvironmentMoved event,
  ) async* {
    // Pega todas as variáveis do ambiente.
    final variables = await _variableRepository.all(event.environment);
    // Aponta o ambiente para outro workspace.
    final environment = event.environment.copyWith(
      workspace: event.workspace,
      active: event.environment.active &&
          event.environment.workspace == event.workspace,
    );
    // Insere no banco o ambiente e suas novas variaveis.
    if (await _environmentRepository.update(environment)) {
      for (final item in variables) {
        await _variableRepository.update(
          item.copyWith(workspace: event.workspace),
        );
      }

      add(EnvironmentFetched());
    }
  }

  Stream<EnvironmentState> _mapEnvironmentDeletedToState(
    EnvironmentDeleted event,
  ) async* {
    await _environmentRepository.delete(event.environment);
    add(EnvironmentFetched());
  }

  Stream<EnvironmentState> _mapEnvironmentClearedToState(
    EnvironmentCleared event,
  ) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    await _environmentRepository.clear(workspace);
    add(EnvironmentFetched());
  }
}
