import 'dart:collection';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:restler/blocs/tab/tab_event.dart';
import 'package:restler/blocs/tab/tab_state.dart';
import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/response_entity.dart';
import 'package:restler/data/entities/tab_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/repositories/collection_repository.dart';
import 'package:restler/data/repositories/response_repository.dart';
import 'package:restler/data/repositories/tab_repository.dart';
import 'package:restler/data/repositories/workspace_repository.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';

class TabBloc extends Bloc<TabEvent, TabState> {
  final _tabRepository = kiwi<TabRepository>();
  final _collectionRepository = kiwi<CollectionRepository>();
  final _responseRepository = kiwi<ResponseRepository>();
  final _workspaceRepository = kiwi<WorkspaceRepository>();
  final _closedTabs = <String, ListQueue<TabEntity>>{};
  final _tabs = <String, List<TabEntity>>{};

  TabBloc()
      : super(
          TabState(
            position: 0,
            tabs: [
              TabEntity(openedAt: currentMillis()),
            ],
          ),
        );

  @override
  Stream<TabState> mapEventToState(TabEvent event) async* {
    if (event is TabFetched) {
      yield* _mapTabFetchedToState();
    } else if (event is TabOpened) {
      yield* _mapTabOpenedToState(event);
    } else if (event is TabEdited) {
      yield* _mapTabEditedToState(event);
    } else if (event is TabSaved) {
      yield* _mapTabSavedToState(event);
    } else if (event is TabSavedAs) {
      yield* _mapTabSavedAsToState(event);
    } else if (event is TabClosed) {
      yield* _mapTabClosedToState(event);
    } else if (event is TabReopened) {
      yield* _mapTabReopenedToState();
    } else if (event is TabReseted) {
      yield* _mapTabResetedToState(event);
    } else if (event is TabDuplicated) {
      yield* _mapTabDuplicatedToState();
    } else if (event is TabRenamed) {
      yield* _mapTabRenamedToState(event);
    } else if (event is TabCallDeleted) {
      yield* _mapTabCallDeletedToState();
    }
  }

  Stream<TabState> _mapTabFetchedToState() async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    // Cache das abas por workspace.
    if (_tabs[workspace.uid] == null || _tabs[workspace.uid].isEmpty) {
      _tabs[workspace.uid] = await _tabRepository.all(workspace);
    }

    final tabs = _tabs[workspace.uid];

    print('Encontrado ${tabs.length} abas');
    tabs.forEach(print);

    if (tabs.isNotEmpty) {
      yield TabState(tabs: tabs, position: 0);
    } else {
      final tab = await _createEmptyTab(workspace);

      if (tab != null) {
        yield TabState(tabs: [tab], position: 0);
      }
    }
  }

  Stream<TabState> _mapTabOpenedToState(TabOpened event) async* {
    final tabs = List.of(state.tabs);
    ResponseEntity response;

    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    // Verificar se já existe uma aba aberta.
    var index = tabs.indexWhere((item) => item.uid == event.tab.uid);
    if (index >= 0) {
      print('substituindo a aba na posição $index...');
      // Atualiza a aba.
      tabs[index] = tabs[index].copyWith(
        openedAt: currentMillis(),
        workspace: workspace,
      );

      if (await _saveOrUpdate(tabs[index])) {
        // Atualiza o cache das abas.
        _tabs[workspace.uid] = tabs;

        yield state.copyWith(tabs: tabs, position: index);

        return;
      }
    }

    // Sempre que abrir uma nova aba, puxar os dados da resposta.
    if (event.tab.response?.uid != null && event.tab.response.size > 0) {
      response = await _responseRepository.get(event.tab.response.uid);
    }

    response ??= event.tab.response;

    // Verificar se já existe uma aba apontando para a mesma chamada.
    index = tabs.indexWhere((item) =>
        item.call != null &&
        item.call.isNotEmpty &&
        item.call == event.tab.call);
    if (index >= 0) {
      print('substituindo a aba com chamada ${event.tab.call}');
      // Substitui a aba.
      tabs[index] = event.tab.copyWith(
        // Mantém o UID da aba existente.
        uid: tabs[index].uid,
        // Copia apenas dos dados do request e do response.
        request: event.tab.request.copyWith(uid: tabs[index].request.uid),
        response: response.copyWith(uid: tabs[index].response.uid),
        workspace: workspace,
      );

      // Atualiza o cache das abas.
      _tabs[workspace.uid] = tabs;

      yield state.copyWith(tabs: tabs, position: index);

      return;
    }

    // Cria uma nova aba.
    if (event.createNew) {
      // Insere no banco e na lista de abas.
      if (await _tabRepository.insert(event.tab)) {
        tabs.add(event.tab.copyWith(
          // Substitui o response por um com body.
          response: response.copyWith(uid: generateUuid()),
          workspace: workspace,
        ));

        // Atualiza o cache das abas.
        _tabs[workspace.uid] = tabs;

        yield state.copyWith(tabs: tabs, position: tabs.length - 1);
      }
    }
    // Substitui a aba atual.
    else {
      index = state.position;
      // Atualiza a aba.
      tabs[index] = event.tab.copyWith(
        // Substitui o response por um com body.
        response: response.copyWith(uid: generateUuid()),
        workspace: workspace,
      );

      // Atualiza o cache das abas.
      _tabs[workspace.uid] = tabs;

      yield state.copyWith(tabs: tabs);
    }
  }

  Stream<TabState> _mapTabClosedToState(TabClosed event) async* {
    final tabs = List.of(state.tabs);

    // Busca a posição da aba.
    final index = tabs.indexWhere((item) => item.uid == event.tab.uid);

    // Aba não encontrada.
    if (index < 0) {
      return;
    }

    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    // Remove a aba do banco e da lista de abas.
    if (await _tabRepository.delete(tabs[index])) {
      if (!_closedTabs.containsKey(workspace.uid)) {
        _closedTabs[workspace.uid] = ListQueue<TabEntity>();
      }

      _closedTabs[workspace.uid].addFirst(tabs[index]);

      tabs.removeAt(index);
    }

    // Nunca deixar vazia.
    if (tabs.isEmpty) {
      final tab = await _createEmptyTab(workspace);

      if (tab != null) {
        tabs.add(tab);
      }
    }

    // Atualiza o cache das abas.
    _tabs[workspace.uid] = tabs;

    yield state.copyWith(
      tabs: tabs,
      position:
          index > state.position ? state.position : max(0, state.position - 1),
    );
  }

  Stream<TabState> _mapTabEditedToState(TabEdited event) async* {
    final tabs = List.of(state.tabs);
    final tab = state.currentTab;
    final index = state.position;
    RequestEntity request;
    ResponseEntity response;

    if (event.request != null) {
      request = tab.request.copyWith(
        header: event.request.header,
        method: event.request.method,
        body: event.request.body,
        auth: event.request.auth,
        query: event.request.query,
        target: event.request.target,
        data: event.request.data,
        notification: event.request.notification,
        type: event.request.type,
        scheme: event.request.scheme,
        url: event.request.url,
        settings: event.request.settings,
        description: event.request.description,
      );
    }

    if (event.response != null) {
      response = event.response;
    }

    final editedTab = tab.copyWith(
      request: request,
      response: response,
      // Estará sempre salvo se não está atrelado a uma chamada.
      saved: request == null ? null : (tab.call == null || tab.call.isEmpty),
    );

    if (await _tabRepository.update(editedTab)) {
      tabs[index] = editedTab;

      // Pega o workspace atual.
      final workspace = await _workspaceRepository.active();
      // Atualiza o cache das abas.
      _tabs[workspace.uid] = tabs;

      yield state.copyWith(tabs: tabs);
    }
  }

  Stream<TabState> _mapTabSavedToState(TabSaved event) async* {
    final tabs = List.of(state.tabs);
    final tab = state.currentTab;
    final index = state.position;

    if (tab.call != null && tab.call.isNotEmpty) {
      final call = await _collectionRepository.getCall(tab.call);

      if (call == null) {
        print('chamada com uid ${tab.call} não foi encontrada');
        return;
      }

      final savedCall = call.copyWith(
        request: tab.request.copyWith(uid: call.request.uid),
      );

      final savedTab = tab.copyWith(saved: true);

      if (await _collectionRepository.updateCall(savedCall) &&
          await _tabRepository.update(savedTab)) {
        tabs[index] = savedTab;

        // Pega o workspace atual.
        final workspace = await _workspaceRepository.active();
        // Atualiza o cache das abas.
        _tabs[workspace.uid] = tabs;

        yield state.copyWith(tabs: tabs);
      }
    }
  }

  Stream<TabState> _mapTabSavedAsToState(TabSavedAs event) async* {
    final tabs = List.of(state.tabs);
    final tab = state.currentTab;
    final index = state.position;

    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    final call = CallEntity(
      uid: generateUuid(),
      name: event.name,
      folder: event.folder,
      request: tab.request.clone(),
      workspace: workspace,
    );

    final savedTab = tab.copyWith(
      saved: true,
      call: call.uid,
      name: call.name,
    );

    if (await _collectionRepository.insertCall(call) &&
        await _tabRepository.update(savedTab)) {
      tabs[index] = savedTab;

      // Atualiza o cache das abas.
      _tabs[workspace.uid] = tabs;

      yield state.copyWith(tabs: tabs);
    }
  }

  Stream<TabState> _mapTabReopenedToState() async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    if (_closedTabs.containsKey(workspace.uid) &&
        _closedTabs[workspace.uid].isNotEmpty) {
      final tab = _closedTabs[workspace.uid].removeFirst();
      add(TabOpened(tab, createNew: true));
    }
  }

  Stream<TabState> _mapTabResetedToState(TabReseted event) async* {
    final tabs = List.of(state.tabs);
    final tab = state.currentTab;
    final index = state.position;

    TabEntity resetedTab;

    // Resetar uma chamada somente se as alterações não foram salvas e está atrelada a uma chamada.
    if (!tab.saved && tab.call != null && tab.call.isNotEmpty) {
      // Busca a chamada no banco.
      final call = await _collectionRepository.getCall(tab.call);

      if (call == null) {
        print('chamada com uid ${tab.call} não foi encontrada');
        return;
      }

      // A aba deve conter a requisição da chamada.
      resetedTab = tab.copyWith(
        saved: true,
        request: call.request.copyWith(uid: tab.request.uid),
        // response: ResponseEntity.empty,
      );
    }
    // Caso contrário limpa todos os dados de requisição da chamada. (o mesmo que RequestCleared)
    else {
      // A aba deve conter a requisição da chamada.
      resetedTab = tab.copyWith(
        saved: true,
        request: RequestEntity.empty.copyWith(uid: tab.request.uid),
        // response: ResponseEntity.empty,
      );
    }

    // Atualiza a aba no banco.
    if (await _tabRepository.update(resetedTab)) {
      tabs[index] = resetedTab;

      // Pega o workspace atual.
      final workspace = await _workspaceRepository.active();
      // Atualiza o cache das abas.
      _tabs[workspace.uid] = tabs;

      yield state.copyWith(tabs: tabs);
    }
  }

  Stream<TabState> _mapTabDuplicatedToState() async* {
    final tabs = List.of(state.tabs);
    final tab = state.currentTab;
    final index = state.position;

    // Duplica a aba.
    final duplicatedTab = TabEntity(
      uid: generateUuid(),
      name: tab.name,
      request: tab.request.clone(),
      // response: tab.response.copyWith(uid: generateUuid()),
      // call: tab.call,
      favorited: tab.favorited,
      openedAt: tab.openedAt,
      saved: true,
      workspace: tab.workspace,
    );

    // Insere no banco e na lista de abas.
    if (await _tabRepository.insert(duplicatedTab)) {
      tabs.insert(index, duplicatedTab);

      // Pega o workspace atual.
      final workspace = await _workspaceRepository.active();
      // Atualiza o cache das abas.
      _tabs[workspace.uid] = tabs;

      yield state.copyWith(tabs: tabs);
    }
  }

  Stream<TabState> _mapTabRenamedToState(TabRenamed event) async* {
    final tabs = List.of(state.tabs);
    final tab = state.currentTab;
    final index = state.position;

    // Renomear a aba.
    final renamedTab = tab.copyWith(
      name: event.name,
      saved: true,
    );

    // Insere no banco e na lista de abas.
    if (await _saveOrUpdate(renamedTab)) {
      tabs[index] = renamedTab;

      // Pega o workspace atual.
      final workspace = await _workspaceRepository.active();
      // Atualiza o cache das abas.
      _tabs[workspace.uid] = tabs;

      yield state.copyWith(tabs: tabs);
    }
  }

  Stream<TabState> _mapTabCallDeletedToState() async* {
    final tabs = List.of(state.tabs);
    var counter = 0;

    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    // Para cada aba, verificar se a chamada existe.
    for (var i = 0; i < tabs.length; i++) {
      final tab = tabs[i];

      if (tab.call != null && tab.call.isNotEmpty) {
        // Busca a chamada entre todos os workspaces.
        final call = await _collectionRepository.getCall(tab.call);

        // A chamada foi excluída.
        // ou a chamada foi movida para outro workspace.
        if (call == null || call.workspace?.uid != workspace?.uid) {
          print('Removendo a chamada da aba $tab');

          // Desatrela a chamada da aba.
          final newTab = tab.copyWith(call: '', saved: true);

          if (await _tabRepository.update(newTab)) {
            tabs[i] = newTab;
            counter++;
          }
        }
      }
    }

    if (counter > 0) {
      // Pega o workspace atual.
      final workspace = await _workspaceRepository.active();
      // Atualiza o cache das abas.
      _tabs[workspace.uid] = tabs;

      yield state.copyWith(tabs: tabs);
    }
  }

  Future<bool> _saveOrUpdate(TabEntity tab) async {
    return await _tabRepository.update(tab) || await _tabRepository.insert(tab);
  }

  Future<TabEntity> _createEmptyTab(WorkspaceEntity workspace) async {
    final emptyTab = TabEntity(
      uid: generateUuid(),
      request: RequestEntity.empty.copyWith(uid: generateUuid()),
      response: ResponseEntity.empty.copyWith(uid: generateUuid()),
      saved: true, // Não há chamada atrelada a ela.
      openedAt: currentMillis(),
      workspace: workspace,
    );

    return await _tabRepository.insert(emptyTab) ? emptyTab : null;
  }
}
