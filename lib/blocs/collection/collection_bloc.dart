import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:path/path.dart' as p;
import 'package:restio/restio.dart';
import 'package:restler/blocs/collection/collection_event.dart';
import 'package:restler/blocs/collection/collection_state.dart';
import 'package:restler/blocs/constants.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/repositories/collection_repository.dart';
import 'package:restler/data/repositories/cookie_repository.dart';
import 'package:restler/data/repositories/dns_repository.dart';
import 'package:restler/data/repositories/environment_repository.dart';
import 'package:restler/data/repositories/proxy_repository.dart';
import 'package:restler/data/repositories/variable_repository.dart';
import 'package:restler/data/repositories/workspace_repository.dart';
import 'package:restler/helper.dart';
import 'package:restler/inject.dart';
import 'package:restler/messager.dart';
import 'package:restler/services/import_export.dart';
import 'package:rxdart/rxdart.dart';

final client = Restio();

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final _collectionRepository = kiwi<CollectionRepository>();
  final _cookieRepository = kiwi<CookieRepository>();
  final _proxyRepository = kiwi<ProxyRepository>();
  final _dnsRepository = kiwi<DnsRepository>();
  final _workspaceRepository = kiwi<WorkspaceRepository>();
  final _environmentRepository = kiwi<EnvironmentRepository>();
  final _variableRepository = kiwi<VariableRepository>();
  final _messager = kiwi<Messager>();

  CollectionBloc() : super(const CollectionState());

  @override
  Stream<Transition<CollectionEvent, CollectionState>> transformTransitions(
    Stream<Transition<CollectionEvent, CollectionState>> transitions,
  ) {
    final debounceStream = transitions
        .where((event) => event.event is SearchTextChanged)
        .debounceTime(const Duration(milliseconds: searchTextDebounceTime));
    final nonDebounceStream =
        transitions.where((event) => event.event is! SearchTextChanged);

    return Rx.merge([debounceStream, nonDebounceStream]);
  }

  @override
  Stream<CollectionState> mapEventToState(CollectionEvent event) async* {
    if (event is SearchTextChanged) {
      yield* _mapSearchTextChangedToState(event);
    } else if (event is SearchToggled) {
      yield* _mapSearchToggledToState(event);
    } else if (event is CollectionFetched) {
      yield* _mapCollectionFetchedToState(event);
    } else if (event is FolderCreated) {
      yield* _mapFolderCreatedToState(event);
    } else if (event is FolderEdited) {
      yield* _mapFolderEditedToState(event);
    } else if (event is FolderMoved) {
      yield* _mapFolderMovedToState(event);
    } else if (event is FolderDeleted) {
      yield* _mapFolderDeletedToState(event);
    } else if (event is CallDuplicated) {
      yield* _mapCallDuplicatedToState(event);
    } else if (event is CallEdited) {
      yield* _mapCallEditedToState(event);
    } else if (event is CallMoved) {
      yield* _mapCallMovedToState(event);
    } else if (event is CallCopied) {
      yield* _mapCallCopiedToState(event);
    } else if (event is CallDeleted) {
      yield* _mapCallDeletedToState(event);
    } else if (event is Forwarded) {
      yield* _mapForwardedToState(event);
    } else if (event is Backwarded) {
      yield* _mapBackwardedToState(event);
    } else if (event is CollectionImported) {
      yield* _mapCollectionImportedToState(event);
    } else if (event is CollectionExported) {
      yield* _mapCollectionExportedToState(event);
    }
  }

  Stream<CollectionState> _mapSearchTextChangedToState(
    SearchTextChanged event,
  ) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    final data = await _collectionRepository.search(
      workspace,
      text: event.text,
      folder: state.folder,
    );

    yield state.copyWith(data: data, searchText: event.text);
  }

  Stream<CollectionState> _mapSearchToggledToState(SearchToggled event) async* {
    yield state.copyWith(search: !state.search);
  }

  Stream<CollectionState> _mapCollectionFetchedToState(
    CollectionFetched event,
  ) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    final data = await _collectionRepository.search(
      workspace,
      text: state.searchText,
      folder: state.folder,
    );

    yield state.copyWith(data: data);
  }

  Stream<CollectionState> _mapFolderCreatedToState(FolderCreated event) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    final folder = FolderEntity(
      uid: generateUuid(),
      name: event.name,
      parent: state.folder,
      workspace: workspace,
    );

    await _collectionRepository.insertFolder(folder);

    add(CollectionFetched());
  }

  Stream<CollectionState> _mapFolderEditedToState(FolderEdited event) async* {
    await _collectionRepository.updateFolder(event.folder);

    add(CollectionFetched());
  }

  Stream<CollectionState> _mapFolderMovedToState(FolderMoved event) async* {
    // Pasta inválida não pode ser movida.
    if (event.folder?.uid == null) {
      return;
    }

    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    // Mover uma pasta, move também todas as suas chamadas e pastas.
    if (await _moveFolderToWorkspace(
        event.folder, event.parent, workspace, event.workspace)) {
      add(CollectionFetched());
    }
  }

  Future<bool> _moveFolderToWorkspace(
    final FolderEntity folder, // Pasta a mover.
    final FolderEntity parent, // Pasta destino (pasta-pai da pasta a mover).
    WorkspaceEntity currentWorkspace,
    WorkspaceEntity newWorkspace,
  ) async {
    // Buscar todas as pastas dentro da pasta a mover.
    final folders = await _collectionRepository.searchFolder(
      currentWorkspace,
      parent: folder,
    );

    // Mover também todas as suas subpastas (setar apenas seu workspace).
    for (final folder in folders) {
      if (!await _moveFolderToWorkspace(
          folder, null, currentWorkspace, newWorkspace)) {
        return false;
      }
    }

    // Mover todas as suas chamadas (setar apenas seu workspace).
    final calls = await _collectionRepository.searchCall(
      currentWorkspace,
      folder: folder,
    );

    for (final call in calls) {
      // Alterar o workspace da chamada.
      final newCall = call.copyWith(workspace: newWorkspace);

      // Atualizar a chamada no banco.
      if (!await _collectionRepository.updateCall(newCall)) {
        return false;
      }
    }

    // Alterar o workspace e a pasta-pai da pasta a mover.
    // As pastas-filho recebem parent nulo, então a pasta-pai não é alterado.
    final newFolder = folder.copyWith(workspace: newWorkspace, parent: parent);

    // Atualizar a pasta no banco.
    if (!await _collectionRepository.updateFolder(newFolder)) {
      return false;
    }

    return true;
  }

  Stream<CollectionState> _mapFolderDeletedToState(FolderDeleted event) async* {
    await _collectionRepository.deleteFolder(event.folder);

    add(CollectionFetched());
  }

  Stream<CollectionState> _mapCallDuplicatedToState(
    CallDuplicated event,
  ) async* {
    final call = event.call.copyWith(
      uid: generateUuid(),
      request: event.call.request.copyWith(uid: generateUuid()),
    );

    await _collectionRepository.insertCall(call);

    add(CollectionFetched());
  }

  Stream<CollectionState> _mapCallEditedToState(CallEdited event) async* {
    await _collectionRepository.updateCall(event.call);

    add(CollectionFetched());
  }

  Stream<CollectionState> _mapCallMovedToState(CallMoved event) async* {
    final call = event.call.copyWith(
      workspace: event.workspace,
      folder: event.folder,
    );

    await _collectionRepository.updateCall(call);

    add(CollectionFetched());
  }

  Stream<CollectionState> _mapCallCopiedToState(CallCopied event) async* {
    final call = event.call.copyWith(
      uid: generateUuid(),
      name: event.name,
      request: event.call.request.copyWith(uid: generateUuid()),
      workspace: event.workspace,
      folder: event.folder,
    );

    await _collectionRepository.insertCall(call);

    add(CollectionFetched());
  }

  Stream<CollectionState> _mapCallDeletedToState(CallDeleted event) async* {
    await _collectionRepository.deleteCall(event.call);

    add(CollectionFetched());
  }

  Stream<CollectionState> _mapForwardedToState(Forwarded event) async* {
    yield state.copyWith(folder: event.folder);

    add(CollectionFetched());
  }

  Stream<CollectionState> _mapBackwardedToState(Backwarded event) async* {
    yield state.copyWith(folder: state.folder.parent ?? FolderEntity.root);

    add(CollectionFetched());
  }

  Stream<CollectionState> _mapCollectionImportedToState(
    CollectionImported event,
  ) async* {
    final path = event.data.filepathOrUrl;
    final type = event.data.type;
    final parent = event.parent ?? FolderEntity.root;
    final password = event.data.password;

    if (path.startsWith('http://') || path.startsWith('https://')) {
      await _importCollectionFromUrl(path, type, parent, password);
    } else if (path.startsWith('/')) {
      await _importCollectionFromFile(path, type, parent, password);
    } else {
      return;
    }

    add(CollectionFetched(forced: true));
  }

  Future<void> _importCollectionFromFile(
    String path,
    ImportType type,
    FolderEntity parent,
    String password,
  ) async {
    final file = File(path);
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();

    try {
      if (file.existsSync()) {
        final text = await file.readAsString();
        final fileType = type == ImportType.insomniaJson ? 'json' : 'yaml';
        ImportExportData data;

        if (type == ImportType.restler) {
          data = Importer.restler().importFromText(
            text,
            password: password,
          );
        } else if (type == ImportType.postman) {
          data = Importer.postman(workspace).importFromText(text);
        } else {
          data = Importer.insomnia(workspace).importFromText(
            text,
            fileType: fileType,
          );
        }

        if (data != null) {
          await _importCollection(data, parent);
          return;
        }
      }
    } on ImportException catch (e) {
      _messager.show((i18n) => e.message);
    } on FormatException catch (e) {
      _messager.show((i18n) => e.message);
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      _messager.show((i18n) => i18n.importError);
    }
  }

  Future<void> _importCollectionFromUrl(
    String url,
    ImportType type,
    FolderEntity parent,
    String password,
  ) async {
    final request = Request.get(url);
    final call = client.newCall(request);

    Response response;

    try {
      response = await call.execute();

      if (response.isSuccess) {
        // Pega o workspace atual.
        final workspace = await _workspaceRepository.active();

        final text = await response.body.string();
        final fileType = type == ImportType.insomniaJson ? 'json' : 'yaml';
        ImportExportData data;

        if (type == ImportType.restler) {
          data = Importer.restler().importFromText(
            text,
            password: password,
          );
        } else if (type == ImportType.postman) {
          data = Importer.postman(workspace).importFromText(text);
        } else {
          data = Importer.insomnia(workspace).importFromText(
            text,
            fileType: fileType,
          );
        }

        if (data != null) {
          await _importCollection(data, parent);
          return;
        }
      }
    } on ImportException catch (e) {
      _messager.show((i18n) => e.message);
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      _messager.show((i18n) => i18n.importError);
    } finally {
      await response?.close();
    }
  }

  Future<void> _importCollection(
    ImportExportData data,
    FolderEntity parent,
  ) async {
    // Workspaces.
    for (final workspace in data.workspaces) {
      if (!await _workspaceRepository.update(workspace)) {
        await _workspaceRepository.insert(workspace);
      }
    }

    // Environments.
    for (final environment in data.environments) {
      if (!await _environmentRepository.update(environment)) {
        await _environmentRepository.insert(environment);
      }
    }

    // Variables.
    for (final variable in data.variables) {
      if (!await _variableRepository.update(variable)) {
        await _variableRepository.insert(variable);
      }
    }

    // Pastas.
    for (var folder in data.folders) {
      if (folder.parent == FolderEntity.root && folder.parent != parent) {
        folder = folder.copyWith(parent: parent);
      }

      if (!await _collectionRepository.updateFolder(folder)) {
        await _collectionRepository.insertFolder(folder);
      }
    }

    // Requests.
    for (var request in data.requests) {
      if (request.folder == FolderEntity.root && request.folder != parent) {
        request = request.copyWith(folder: parent);
      }

      if (!await _collectionRepository.updateCall(request)) {
        await _collectionRepository.insertCall(request);
      }
    }

    // Cookies.
    for (final cookie in data.cookies) {
      if (!await _cookieRepository.update(cookie)) {
        await _cookieRepository.insert(cookie);
      }
    }

    // Proxies.
    for (final proxy in data.proxies) {
      if (!await _proxyRepository.update(proxy)) {
        await _proxyRepository.insert(proxy);
      }
    }

    // DNS.
    for (final dns in data.dns) {
      if (!await _dnsRepository.update(dns)) {
        await _dnsRepository.insert(dns);
      }
    }

    // Recarrega para pegar as pastas e chamadas do workspace atual.
    add(CollectionFetched(forced: true));

    _messager.show((i18n) => i18n.collectionImported);
  }

  Stream<CollectionState> _mapCollectionExportedToState(
    CollectionExported event,
  ) async* {
    // Pega o workspace atual.
    final workspace = await _workspaceRepository.active();
    // Pega todas as pastas e chamadas.
    final folders = await _collectionRepository.allFolders(workspace);
    final requests = await _collectionRepository.allCalls(workspace);
    // Pega todos os cookies.
    final cookies = await _cookieRepository.all(workspace);
    // Pega todos os proxies.
    final proxies = await _proxyRepository.all(workspace);
    // Pega todos os DNSs.
    final dns = await _dnsRepository.all(workspace);

    final data = ImportExportData(
      workspaces: [workspace],
      folders: folders,
      requests: requests,
      cookies: cookies,
      proxies: proxies,
      dns: dns,
    );

    String text;
    String fileType;

    try {
      if (event.data.type == ExportType.restler) {
        fileType = 'json';
        text = Exporter.restler().export(data, password: event.data.password);
      } else if (event.data.type == ExportType.postman) {
        fileType = 'json';
        text = Exporter.postman().export(data, name: event.data.name);
      } else {
        fileType = event.data.type == ExportType.insomniaJson ? 'json' : 'yaml';
        text = Exporter.insomnia().export(data, fileType: fileType);
      }

      // Salva num arquivo.
      final path = p.join(event.path, '${currentMillis()}.$fileType');
      final file = File(path);
      await file.writeAsString(text);
      _messager.show((i18n) => i18n.fileSavedAt(path));
    } catch (e) {
      _messager.show((i18n) => i18n.exportError(e.toString()));
    }
  }
}
