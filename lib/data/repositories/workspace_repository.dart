import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/providers/workspace_provider.dart';

class WorkspaceRepository {
  final WorkspaceProvider workspaceProvider;

  WorkspaceRepository(this.workspaceProvider);

  Future<List<WorkspaceEntity>> all() async {
    final data = await workspaceProvider.all();
    return [for (final item in data) WorkspaceEntity.fromDatabase(item)];
  }

  Future<bool> has(WorkspaceEntity workspace) async {
    return workspaceProvider.has(workspace.uid);
  }

  Future<bool> insert(WorkspaceEntity workspace) async {
    return workspaceProvider.insert(workspace.toDatabase());
  }

  Future<bool> update(WorkspaceEntity workspace) async {
    return workspaceProvider.update(workspace.uid, workspace.toDatabase());
  }

  Future<bool> delete(WorkspaceEntity workspace) async {
    return workspaceProvider.delete(workspace.uid);
  }

  Future<WorkspaceEntity> get(String uid) async {
    final item = await workspaceProvider.get(uid);
    return WorkspaceEntity.fromDatabase(item);
  }

  Future<WorkspaceEntity> active() async {
    final item = await workspaceProvider.active();
    return item == null || item['ws_active'] != 1
        ? WorkspaceEntity.empty
        : WorkspaceEntity.fromDatabase(item);
  }
}
