import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restler/blocs/workspace/workspace_event.dart';
import 'package:restler/blocs/workspace/workspace_state.dart';
import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/repositories/certificate_repository.dart';
import 'package:restler/data/repositories/collection_repository.dart';
import 'package:restler/data/repositories/cookie_repository.dart';
import 'package:restler/data/repositories/dns_repository.dart';
import 'package:restler/data/repositories/environment_repository.dart';
import 'package:restler/data/repositories/proxy_repository.dart';
import 'package:restler/data/repositories/variable_repository.dart';
import 'package:restler/data/repositories/workspace_repository.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final _workspaceRepository = kiwi<WorkspaceRepository>();
  final _collectionRepository = kiwi<CollectionRepository>();
  final _cookieRepository = kiwi<CookieRepository>();
  final _certificateRepository = kiwi<CertificateRepository>();
  final _proxyRepository = kiwi<ProxyRepository>();
  final _dnsRepository = kiwi<DnsRepository>();
  final _environmentRepository = kiwi<EnvironmentRepository>();
  final _variableRepository = kiwi<VariableRepository>();

  WorkspaceBloc() : super(const WorkspaceState());

  @override
  Stream<WorkspaceState> mapEventToState(WorkspaceEvent event) async* {
    if (event is WorkspaceFetched) {
      yield* _mapWorkspaceFetchedToState();
    } else if (event is WorkspaceSelected) {
      yield* _mapWorkspaceSelectedToState(event);
    } else if (event is EnvironmentSelected) {
      yield* _mapEnvironmentSelectedToState(event);
    } else if (event is WorkspaceCreated) {
      yield* _mapWorkspaceCreatedToState(event);
    } else if (event is WorkspaceEdited) {
      yield* _mapWorkspaceEditedToState(event);
    } else if (event is WorkspaceDeleted) {
      yield* _mapWorkspaceDeletedToState(event);
    } else if (event is WorkspaceCleared) {
      yield* _mapWorkspaceClearedToState(event);
    } else if (event is WorkspaceDuplicated) {
      yield* _mapWorkspaceDuplicatedToState(event);
    }
  }

  Stream<WorkspaceState> _mapWorkspaceFetchedToState() async* {
    final workspaces = await _workspaceRepository.all();
    final workspace = await _workspaceRepository.active();
    final environments = await _environmentRepository.all(workspace);
    final environment = await _environmentRepository.active(workspace);

    yield state.copyWith(
      workspaces: [
        WorkspaceEntity.empty,
        ...workspaces,
      ],
      currentWorkspace: workspaces.isNotEmpty && workspaces[0].active
          ? workspaces[0]
          : WorkspaceEntity.empty,
      environments: [
        // No environment.
        EnvironmentEntity.noEnvironment(workspace),
        ...environments,
      ],
      currentEnvironment: environment,
    );
  }

  Stream<WorkspaceState> _mapWorkspaceSelectedToState(
    WorkspaceSelected event,
  ) async* {
    // Deseleciona todos, exceto o que será selecionado.
    final workspaces = [
      for (final item in state.workspaces)
        item.copyWith(active: item.uid == event.workspace.uid),
    ];

    // Atualiza no banco.
    for (final item in workspaces) {
      if (item.uid != null) {
        await _workspaceRepository.update(item);
      }
    }

    final workspace = event.workspace.copyWith(active: true);

    final environments = await _environmentRepository.all(workspace);
    final environment = await _environmentRepository.active(workspace);

    yield state.copyWith(
      workspaces: workspaces,
      currentWorkspace: workspace,
      environments: [
        // No environment.
        EnvironmentEntity.noEnvironment(workspace),
        ...environments,
      ],
      currentEnvironment: environment,
    );
  }

  Stream<WorkspaceState> _mapEnvironmentSelectedToState(
    EnvironmentSelected event,
  ) async* {
    // Deseleciona todos, exceto o que será selecionado.
    final environments = [
      for (final item in state.environments)
        item.copyWith(active: item.uid == event.environment.uid),
    ];

    // Atualiza no banco.
    for (final item in environments) {
      if (!item.isNoEnvironment) {
        await _environmentRepository.update(item);
      }
    }

    final environment = event.environment.copyWith(active: true);

    yield state.copyWith(
      environments: environments,
      currentEnvironment: environment,
    );
  }

  Stream<WorkspaceState> _mapWorkspaceCreatedToState(
    WorkspaceCreated event,
  ) async* {
    final data = List.of(state.workspaces);

    final created = WorkspaceEntity(
      uid: generateUuid(),
      name: event.name,
    );

    if (await _workspaceRepository.insert(created)) {
      data.add(created);

      yield state.copyWith(workspaces: data);
    }

    add(WorkspaceSelected(created));
  }

  Stream<WorkspaceState> _mapWorkspaceEditedToState(
    WorkspaceEdited event,
  ) async* {
    // Workspace padrão não pode ser editado.
    if (state.currentWorkspace?.uid == null) {
      return;
    }

    final data = List.of(state.workspaces);

    // Busca a posição na lista pra poder ser atualizado.
    final index =
        data.indexWhere((item) => item.uid == state.currentWorkspace.uid);

    if (index == -1) {
      return;
    }

    final edited = state.currentWorkspace.copyWith(name: event.name);

    if (await _workspaceRepository.update(edited)) {
      data[index] = edited;

      yield state.copyWith(workspaces: data, currentWorkspace: edited);
    }
  }

  Stream<WorkspaceState> _mapWorkspaceDeletedToState(
    WorkspaceDeleted event,
  ) async* {
    // Workspace padrão não pode ser excluído.
    if (state.currentWorkspace?.uid == null) {
      return;
    }

    final data = List.of(state.workspaces);

    // Busca a posição na lista pra poder ser excluído.
    final index =
        data.indexWhere((item) => item.uid == state.currentWorkspace.uid);

    if (index == -1) {
      return;
    }

    final deleted = data[index];

    await _clearWorkspace(deleted);

    if (await _workspaceRepository.delete(deleted)) {
      data.removeAt(index);

      yield state.copyWith(workspaces: data, currentWorkspace: data[0]);

      add(WorkspaceSelected(data[0]));
    }
  }

  Stream<WorkspaceState> _mapWorkspaceClearedToState(
    WorkspaceCleared event,
  ) async* {
    await _clearWorkspace(state.currentWorkspace);
    add(WorkspaceSelected(state.currentWorkspace));
  }

  Stream<WorkspaceState> _mapWorkspaceDuplicatedToState(
    WorkspaceDuplicated event,
  ) async* {
    final workspace = state.currentWorkspace;

    // Duplicar pastas e chamadas.
    if (await _duplicateWorkspace(workspace)) {
      final workspaces = await _workspaceRepository.all();

      yield state.copyWith(
        workspaces: [
          WorkspaceEntity.empty,
          ...workspaces,
        ],
      );
    }
  }

  Future<bool> _duplicateWorkspace(WorkspaceEntity workspace) async {
    // Duplicar o workspace.
    final newWorkspace = workspace.copyWith(
      uid: generateUuid(),
      name: '${workspace.name} (copy)',
      active: false,
    );

    return await _workspaceRepository.insert(newWorkspace) &&
        // Duplicar a coleção.
        await _duplicateCollection(workspace, newWorkspace, null) &&
        // Duplicar os cookies.
        await _duplicateCookies(workspace, newWorkspace) &&
        // Duplicar os certificados.
        await _duplicateCertificates(workspace, newWorkspace) &&
        // Duplicar os proxies.
        await _duplicateProxies(workspace, newWorkspace) &&
        // Duplicar os DNS.
        await _duplicateDNSs(workspace, newWorkspace) &&
        // Duplicar os ambientes e suas variaveis.
        await _duplicateEnvironmentAndVariables(workspace, newWorkspace);
  }

  Future<bool> _duplicateCollection(
    WorkspaceEntity currentWorkspace,
    WorkspaceEntity newWorkspace,
    final FolderEntity parent,
  ) async {
    // Buscar as pastas dentro de parent.
    final folders = await _collectionRepository.searchFolder(
      currentWorkspace,
      parent: parent,
    );

    // Navegar pelas pastas e fazer tudo isso de novo.
    for (final folder in folders) {
      if (!await _duplicateCollection(currentWorkspace, newWorkspace, folder)) {
        return false;
      }
    }

    // Duplicar apenas as pastas que não são raiz.
    final newFolder = parent?.uid != null
        ? parent.copyWith(uid: generateUuid(), workspace: newWorkspace)
        : FolderEntity.root;

    // Duplicar a pasta.
    if (newFolder?.uid != null) {
      if (!await _collectionRepository.insertFolder(newFolder)) {
        return false;
      }
    }

    // Buscar as chamadas dentro da pasta.
    final calls = await _collectionRepository.searchCall(
      currentWorkspace,
      folder: parent,
    );

    // Duplicar as chamadas.
    for (final call in calls) {
      final newCall = call.copyWith(
        uid: generateUuid(),
        workspace: newWorkspace,
        folder: newFolder,
        request: call.request.copyWith(uid: generateUuid()),
      );

      if (!await _collectionRepository.insertCall(newCall)) {
        return false;
      }
    }

    return true;
  }

  Future<bool> _duplicateCookies(
    WorkspaceEntity currentWorkspace,
    WorkspaceEntity newWorkspace,
  ) async {
    final cookies = await _cookieRepository.all(currentWorkspace);

    for (final cookie in cookies) {
      final newCookie = cookie.copyWith(
        uid: generateUuid(),
        workspace: newWorkspace,
      );

      if (!await _cookieRepository.insert(newCookie)) {
        return false;
      }
    }

    return true;
  }

  Future<bool> _duplicateCertificates(
    WorkspaceEntity currentWorkspace,
    WorkspaceEntity newWorkspace,
  ) async {
    final certificates = await _certificateRepository.all(currentWorkspace);

    for (final certificate in certificates) {
      final newCertificate = certificate.copyWith(
        uid: generateUuid(),
        workspace: newWorkspace,
      );

      if (!await _certificateRepository.insert(newCertificate)) {
        return false;
      }
    }

    return true;
  }

  Future<bool> _duplicateProxies(
    WorkspaceEntity currentWorkspace,
    WorkspaceEntity newWorkspace,
  ) async {
    final proxies = await _proxyRepository.all(currentWorkspace);

    for (final proxy in proxies) {
      final newProxy = proxy.copyWith(
        uid: generateUuid(),
        workspace: newWorkspace,
      );

      if (!await _proxyRepository.insert(newProxy)) {
        return false;
      }
    }

    return true;
  }

  Future<bool> _duplicateDNSs(
    WorkspaceEntity currentWorkspace,
    WorkspaceEntity newWorkspace,
  ) async {
    final dnss = await _dnsRepository.all(currentWorkspace);

    for (final dns in dnss) {
      final newDNS = dns.copyWith(
        uid: generateUuid(),
        workspace: newWorkspace,
      );

      if (!await _dnsRepository.insert(newDNS)) {
        return false;
      }
    }

    return true;
  }

  Future<bool> _duplicateEnvironmentAndVariables(
    WorkspaceEntity currentWorkspace,
    WorkspaceEntity newWorkspace,
  ) async {
    // Duplicar os ambientes.
    final environments = [
      EnvironmentEntity.none.copyWith(workspace: currentWorkspace), // Global.
      ...await _environmentRepository.all(currentWorkspace),
    ];

    for (final environment in environments) {
      var newEnvironment = environment;

      if (environment.uid != null) {
        newEnvironment = environment.copyWith(
          uid: generateUuid(),
          active: false,
          workspace: newWorkspace,
        );

        // Insere o ambiente no banco.
        if (!await _environmentRepository.insert(newEnvironment)) {
          return false;
        }
      } else {
        newEnvironment = environment.copyWith(
          active: false,
          workspace: newWorkspace,
        );
      }

      // Duplica as variáveis do ambiente.
      final variables = await _variableRepository.all(environment);

      for (final variable in variables) {
        final newVariable = variable.copyWith(
          uid: generateUuid(),
          environment: newEnvironment,
          workspace: newWorkspace,
        );

        // Insere a variável no banco.
        if (!await _variableRepository.insert(newVariable)) {
          return false;
        }
      }
    }

    return true;
  }

  Future<void> _clearWorkspace(WorkspaceEntity workspace) async {
    // Remove cookies.
    await _cookieRepository.clear(workspace);
    // Remove certificados.
    await _certificateRepository.clear(workspace);
    // Remove proxies.
    await _proxyRepository.clear(workspace);
    // Remove DNSs.
    await _dnsRepository.clear(workspace);
    // Remove ambientes.
    await _environmentRepository.clear(workspace);
    // Remove as pastas e suas chamadas.
    _collectionRepository.clear(workspace);
  }
}
