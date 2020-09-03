import 'package:bloc/bloc.dart';
import 'package:restler/blocs/constants.dart';
import 'package:restler/blocs/cookie/cookie_event.dart';
import 'package:restler/blocs/cookie/cookie_state.dart';
import 'package:restler/data/repositories/cookie_repository.dart';
import 'package:restler/data/repositories/workspace_repository.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:rxdart/rxdart.dart';

class CookieBloc extends Bloc<CookieEvent, CookieState> {
  final _cookieRepository = kiwi<CookieRepository>();
  final _workspaceRepository = kiwi<WorkspaceRepository>();

  CookieBloc() : super(const CookieState());

  @override
  Stream<Transition<CookieEvent, CookieState>> transformTransitions(
    Stream<Transition<CookieEvent, CookieState>> transitions,
  ) {
    final debounceStream = transitions
        .where((event) => event.event is SearchTextChanged)
        .debounceTime(const Duration(milliseconds: searchTextDebounceTime));
    final nonDebounceStream =
        transitions.where((event) => event.event is! SearchTextChanged);

    return Rx.merge([debounceStream, nonDebounceStream]);
  }

  @override
  Stream<CookieState> mapEventToState(CookieEvent event) async* {
    if (event is SearchTextChanged) {
      yield* _mapSearchTextChangedToState(event);
    } else if (event is SearchToggled) {
      yield* _mapSearchToggledToState(event);
    } else if (event is CookieFetched) {
      yield* _mapCookieFetchedToState(event);
    } else if (event is CookieCreated) {
      yield* _mapCookieCreatedToState(event);
    } else if (event is CookieEdited) {
      yield* _mapCookieEditedToState(event);
    } else if (event is CookieDuplicated) {
      yield* _mapCookieDuplicatedToState(event);
    } else if (event is CookieDeleted) {
      yield* _mapCookieDeletedToState(event);
    } else if (event is CookieCleared) {
      yield* _mapCookieClearedToState(event);
    } else if (event is CookieMoved) {
      yield* _mapCookieMovedToState(event);
    } else if (event is CookieCopied) {
      yield* _mapCookieCopiedToState(event);
    }
  }

  Stream<CookieState> _mapSearchTextChangedToState(
    SearchTextChanged event,
  ) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    final data = await _cookieRepository.search(workspace, text: event.text);
    yield state.copyWith(data: data, searchText: event.text);
  }

  Stream<CookieState> _mapSearchToggledToState(SearchToggled event) async* {
    yield state.copyWith(search: !state.search);
  }

  Stream<CookieState> _mapCookieFetchedToState(CookieFetched event) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    final data =
        await _cookieRepository.search(workspace, text: state.searchText);
    yield state.copyWith(data: data);
  }

  Stream<CookieState> _mapCookieCreatedToState(CookieCreated event) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    await _cookieRepository.insert(event.cookie.copyWith(workspace: workspace));
    add(CookieFetched());
  }

  Stream<CookieState> _mapCookieEditedToState(CookieEdited event) async* {
    await _cookieRepository.update(event.cookie);
    add(CookieFetched());
  }

  Stream<CookieState> _mapCookieDuplicatedToState(
    CookieDuplicated event,
  ) async* {
    final cookie = event.cookie.copyWith(uid: generateUuid());
    await _cookieRepository.insert(cookie);
    add(CookieFetched());
  }

  Stream<CookieState> _mapCookieDeletedToState(CookieDeleted event) async* {
    await _cookieRepository.delete(event.cookie);
    add(CookieFetched());
  }

  Stream<CookieState> _mapCookieClearedToState(CookieCleared event) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    await _cookieRepository.clear(workspace);
    add(CookieFetched());
  }

  Stream<CookieState> _mapCookieMovedToState(CookieMoved event) async* {
    if (event.cookie.workspace != event.workspace) {
      // Move o cookie para outro workspace.
      final cookie = event.cookie.copyWith(workspace: event.workspace);
      await _cookieRepository.update(cookie);
      add(CookieFetched());
    }
  }

  Stream<CookieState> _mapCookieCopiedToState(CookieCopied event) async* {
    // Copia o cookie para um workspace.
    final cookie = event.cookie.copyWith(
      uid: generateUuid(),
      workspace: event.workspace,
    );

    await _cookieRepository.insert(cookie);

    add(CookieFetched());
  }
}
