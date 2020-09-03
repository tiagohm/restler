import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/providers/call_provider.dart';
import 'package:restler/data/providers/folder_provider.dart';
import 'package:restler/data/repositories/request_repository.dart';
import 'package:restler/helper.dart';

class CollectionRepository {
  final FolderProvider folderProvider;
  final CallProvider callProvider;
  final RequestRepository requestRepository;

  CollectionRepository(
    this.folderProvider,
    this.callProvider,
    this.requestRepository,
  );

  Future<CallEntity> _buildCall(Map<String, dynamic> data) async {
    return CallEntity(
      uid: data['call_uid'],
      name: data['call_name'],
      folder: await getFolder(data['call_folder']),
      request: RequestEntity.fromDatabase(data) ??
          RequestEntity.empty.copyWith(uid: generateUuid()),
      favorite: data['call_favorite'] == 1,
      workspace: WorkspaceEntity.fromDatabase(data),
    );
  }

  Future<CallEntity> getCall(String uid) async {
    final data = await callProvider.get(uid);

    return data == null ? null : _buildCall(data);
  }

  Future<List<FolderEntity>> allFolders(WorkspaceEntity workspace) async {
    final data = await folderProvider.all(workspace?.uid);

    return [for (final item in data) await _buildFolder(item)];
  }

  Future<List<CallEntity>> allCalls(WorkspaceEntity workspace) async {
    final data = await callProvider.all(workspace?.uid);

    return [for (final item in data) await _buildCall(item)];
  }

  Future<FolderEntity> _buildFolder(Map<String, dynamic> data) async {
    return FolderEntity(
      uid: data['fol_uid'],
      name: data['fol_name'],
      parent: data['fol_parent'] == null
          ? FolderEntity.root
          : await getFolder(data['fol_parent']),
      favorite: data['fol_favorite'] == 1,
      workspace: WorkspaceEntity.fromDatabase(data),
      numberOfCalls: await callProvider.numberOfCalls(data['fol_uid']),
      numberOfFolders: await folderProvider.numberOfFolders(data['fol_uid']),
    );
  }

  Future<FolderEntity> getFolder(String uid) async {
    if (uid == null) {
      return FolderEntity.root;
    }

    final data = await folderProvider.get(uid);

    return data == null ? null : _buildFolder(data);
  }

  Future<bool> insertFolder(FolderEntity folder) async {
    return folderProvider.insert(folder.toDatabase());
  }

  Future<bool> insertCall(CallEntity call) async {
    return (call.request == null ||
            await requestRepository.insert(call.request)) &&
        await callProvider.insert(call.toDatabase());
  }

  Future<bool> updateFolder(FolderEntity folder) async {
    return folderProvider.update(folder.uid, folder.toDatabase());
  }

  Future<bool> updateCall(CallEntity call) async {
    return (call.request == null ||
            await requestRepository.update(call.request)) &&
        await callProvider.update(call.uid, call.toDatabase());
  }

  // Remove uma pasta.
  Future<bool> deleteFolder(FolderEntity folder) async {
    // Pasta inválida.
    if (folder?.uid == null) {
      return false;
    }

    // Remover uma pasta remove também suas sub-pastas.
    final folders = await allFolders(folder.workspace);

    for (final item in folders) {
      // Verifica se é subpasta da pasta removida.
      if (item.parent?.uid == folder.uid) {
        if (!await deleteFolder(item)) {
          return false;
        }
      }
    }

    // Remover uma pasta remove também suas chamadas.
    final calls = await allCalls(folder.workspace);

    for (final item in calls) {
      // Verifica se a chamada pertence a pasta removida.
      if (item.folder?.uid == folder.uid) {
        if (!await deleteCall(item)) {
          return false;
        }
      }
    }

    // Remove do banco.
    if (!await folderProvider.delete(folder.uid)) {
      return false;
    }

    return true;
  }

  Future<bool> deleteCall(CallEntity call) async {
    return await callProvider.delete(call.uid) &&
        (call.request == null || await requestRepository.delete(call.request));
  }

  Future<List<FolderEntity>> searchFolder(
    WorkspaceEntity workspace, {
    String text,
    FolderEntity parent,
  }) async {
    print('searchFolder($workspace, $text, $parent)');

    final data = await folderProvider.search(
      workspace?.uid,
      text: text,
      parent: parent?.uid,
    );

    return [
      for (final item in data) await _buildFolder(item),
    ];
  }

  Future<List<CallEntity>> searchCall(
    WorkspaceEntity workspace, {
    String text,
    FolderEntity folder,
  }) async {
    print('searchCall($workspace, $text, $folder)');

    final data = await callProvider.search(
      workspace?.uid,
      text: text,
      folder: folder?.uid,
    );

    return [
      for (final item in data) await _buildCall(item),
    ];
  }

  Future<List> search(
    WorkspaceEntity workspace, {
    String text,
    FolderEntity folder,
  }) async {
    return [
      ...await searchFolder(workspace, text: text, parent: folder),
      ...await searchCall(workspace, text: text, folder: folder),
    ];
  }

  Future<bool> clear(WorkspaceEntity workspace) async {
    for (final item in await allFolders(workspace)) {
      if (!await deleteFolder(item)) {
        return false;
      }
    }

    for (final item in await allCalls(workspace)) {
      if (!await deleteCall(item)) {
        return false;
      }
    }

    return true;
  }
}
