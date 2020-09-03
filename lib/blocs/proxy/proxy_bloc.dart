import 'package:bloc/bloc.dart';
import 'package:restler/blocs/constants.dart';
import 'package:restler/blocs/proxy/proxy_event.dart';
import 'package:restler/blocs/proxy/proxy_state.dart';
import 'package:restler/data/repositories/proxy_repository.dart';
import 'package:restler/data/repositories/workspace_repository.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:rxdart/rxdart.dart';

class ProxyBloc extends Bloc<ProxyEvent, ProxyState> {
  final _proxyRepository = kiwi<ProxyRepository>();
  final _workspaceRepository = kiwi<WorkspaceRepository>();

  ProxyBloc() : super(const ProxyState());

  @override
  Stream<Transition<ProxyEvent, ProxyState>> transformTransitions(
    Stream<Transition<ProxyEvent, ProxyState>> transitions,
  ) {
    final debounceStream = transitions
        .where((event) => event.event is SearchTextChanged)
        .debounceTime(const Duration(milliseconds: searchTextDebounceTime));
    final nonDebounceStream =
        transitions.where((event) => event.event is! SearchTextChanged);

    return Rx.merge([debounceStream, nonDebounceStream]);
  }

  @override
  Stream<ProxyState> mapEventToState(ProxyEvent event) async* {
    if (event is SearchTextChanged) {
      yield* _mapSearchTextChangedToState(event);
    } else if (event is SearchToggled) {
      yield* _mapSearchToggledToState(event);
    } else if (event is ProxyFetched) {
      yield* _mapProxyFetchedToState(event);
    } else if (event is ProxyCreated) {
      yield* _mapProxyCreatedToState(event);
    } else if (event is ProxyEdited) {
      yield* _mapProxyEditedToState(event);
    } else if (event is ProxyDuplicated) {
      yield* _mapProxyDuplicatedToState(event);
    } else if (event is ProxyDeleted) {
      yield* _mapProxyDeletedToState(event);
    } else if (event is ProxyCleared) {
      yield* _mapProxyClearedToState(event);
    } else if (event is ProxyMoved) {
      yield* _mapProxyMovedToState(event);
    } else if (event is ProxyCopied) {
      yield* _mapProxyCopiedToState(event);
    }
  }

  Stream<ProxyState> _mapSearchTextChangedToState(
    SearchTextChanged event,
  ) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    final data = await _proxyRepository.search(workspace, event.text);
    yield state.copyWith(data: data, searchText: event.text);
  }

  Stream<ProxyState> _mapSearchToggledToState(SearchToggled event) async* {
    yield state.copyWith(search: !state.search);
  }

  Stream<ProxyState> _mapProxyFetchedToState(ProxyFetched event) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    final data = await _proxyRepository.search(workspace, state.searchText);
    yield state.copyWith(data: data);
  }

  Stream<ProxyState> _mapProxyCreatedToState(ProxyCreated event) async* {
    await _proxyRepository.insert(event.proxy);
    add(ProxyFetched());
  }

  Stream<ProxyState> _mapProxyEditedToState(ProxyEdited event) async* {
    await _proxyRepository.update(event.proxy);
    add(ProxyFetched());
  }

  Stream<ProxyState> _mapProxyDuplicatedToState(
    ProxyDuplicated event,
  ) async* {
    final proxy = event.proxy.copyWith(uid: generateUuid());
    await _proxyRepository.insert(proxy);
    add(ProxyFetched());
  }

  Stream<ProxyState> _mapProxyDeletedToState(ProxyDeleted event) async* {
    await _proxyRepository.delete(event.proxy);
    add(ProxyFetched());
  }

  Stream<ProxyState> _mapProxyClearedToState(ProxyCleared event) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    await _proxyRepository.clear(workspace);
    add(ProxyFetched());
  }

  Stream<ProxyState> _mapProxyMovedToState(ProxyMoved event) async* {
    if (event.proxy.workspace != event.workspace) {
      // Antes devemos removê-lo, para não deixar referenciado por uma chamada.
      await _proxyRepository.delete(event.proxy);
      // Copia o proxy para outro workspace.
      add(ProxyCopied(event.proxy, event.workspace));
    }
  }

  Stream<ProxyState> _mapProxyCopiedToState(ProxyCopied event) async* {
    // Copia o proxy para um workspace.
    final proxy = event.proxy.copyWith(
      uid: generateUuid(),
      workspace: event.workspace,
    );

    await _proxyRepository.insert(proxy);

    add(ProxyFetched());
  }
}
