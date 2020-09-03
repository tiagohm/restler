import 'package:bloc/bloc.dart';
import 'package:restler/blocs/constants.dart';
import 'package:restler/blocs/history/history_event.dart';
import 'package:restler/blocs/history/history_state.dart';
import 'package:restler/blocs/history/sort.dart';
import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/data/repositories/collection_repository.dart';
import 'package:restler/data/repositories/history_repository.dart';
import 'package:restler/data/repositories/workspace_repository.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:rxdart/rxdart.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final _historyRepository = kiwi<HistoryRepository>();
  final _collectionRepository = kiwi<CollectionRepository>();
  final _workspaceRepository = kiwi<WorkspaceRepository>();

  HistoryBloc() : super(const HistoryState());

  @override
  Stream<Transition<HistoryEvent, HistoryState>> transformTransitions(
    Stream<Transition<HistoryEvent, HistoryState>> transitions,
  ) {
    final debounceStream = transitions
        .where((event) => event.event is SearchTextChanged)
        .debounceTime(const Duration(milliseconds: searchTextDebounceTime));
    final nonDebounceStream =
        transitions.where((event) => event.event is! SearchTextChanged);

    return Rx.merge([debounceStream, nonDebounceStream]);
  }

  @override
  Stream<HistoryState> mapEventToState(HistoryEvent event) async* {
    if (event is SearchTextChanged) {
      yield* _mapSearchTextChangedToState(event);
    } else if (event is SearchToggled) {
      yield* _mapSearchToggledToState(event);
    } else if (event is HistoryFetched) {
      yield* _mapHistoryFetchedToState(event);
    } else if (event is HistorySaved) {
      yield* _mapHistorySavedToState(event);
    } else if (event is HistorySorted) {
      yield* _mapHistorySortedToState(event);
    } else if (event is HistoryDeleted) {
      yield* _mapHistoryDeletedToState(event);
    } else if (event is HistoryCleared) {
      yield* _mapHistoryClearedToState(event);
    }
  }

  Stream<HistoryState> _mapSearchTextChangedToState(
    SearchTextChanged event,
  ) async* {
    final data = await _historyRepository.search(text: event.text);
    yield state.copyWith(data: data, searchText: event.text);
  }

  Stream<HistoryState> _mapSearchToggledToState(SearchToggled event) async* {
    yield state.copyWith(search: !state.search);
  }

  Stream<HistoryState> _mapHistoryFetchedToState(HistoryFetched event) async* {
    final data = await _historyRepository.search(text: state.searchText);
    yield state.copyWith(data: data);
  }

  Stream<HistoryState> _mapHistorySavedToState(HistorySaved event) async* {
    final request = event.history.request;

    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    final call = CallEntity(
      uid: generateUuid(),
      folder: event.folder,
      name: event.name,
      request: request.clone(),
      workspace: workspace,
    );

    await _collectionRepository.insertCall(call);
  }

  Stream<HistoryState> _mapHistorySortedToState(HistorySorted event) async* {
    final sort = event.sort;
    final data = List.of(state.data);

    data.sort((a, b) {
      var res0 = 0;

      switch (sort.type) {
        case SortType.date:
          res0 = a.date.compareTo(b.date);
          break;
        case SortType.method:
          res0 = a.request.method.compareTo(b.request.method);
          break;
        case SortType.url:
          res0 = a.request.rightUrl.compareTo(b.request.rightUrl);
          break;
        case SortType.status:
          res0 = a.response.status.compareTo(b.response.status);
          break;
        case SortType.duration:
          res0 = a.response.time.compareTo(b.response.time);
          break;
        case SortType.size:
          res0 = a.response.size.compareTo(b.response.size);
          break;
      }

      final res1 = a.date.compareTo(b.date);

      final res = res0 == 0 ? res1 : res0;

      return sort.ascending ? res : -res;
    });

    yield state.copyWith(data: data, sort: sort);
  }

  Stream<HistoryState> _mapHistoryDeletedToState(HistoryDeleted event) async* {
    if (await _historyRepository.delete(event.history)) {
      add(HistoryFetched());
    }
  }

  Stream<HistoryState> _mapHistoryClearedToState(HistoryCleared event) async* {
    if (await _historyRepository.clear()) {
      add(HistoryFetched());
    }
  }
}
