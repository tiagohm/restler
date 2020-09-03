import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/providers/environment_provider.dart';
import 'package:restler/data/providers/variable_provider.dart';

class EnvironmentRepository {
  final EnvironmentProvider environmentProvider;
  final VariableProvider variableProvider;

  EnvironmentRepository(this.environmentProvider, this.variableProvider);

  Future<List<EnvironmentEntity>> all(WorkspaceEntity workspace) async {
    final data = await environmentProvider.all(workspace?.uid);
    return _mapDataToEnvironmentList(data);
  }

  Future<List<EnvironmentEntity>> search(
    WorkspaceEntity workspace, {
    String text = '',
    bool enabled,
  }) async {
    final data = await environmentProvider.search(
      workspace?.uid,
      text: text,
      enabled: enabled,
    );

    return _mapDataToEnvironmentList(data);
  }

  Future<EnvironmentEntity> get(String uid) async {
    final data = await environmentProvider.get(uid);
    return data == null || data.isEmpty
        ? null
        : EnvironmentEntity.fromDatabase(data);
  }

  Future<bool> insert(EnvironmentEntity environment) {
    return environmentProvider.insert(environment.toDatabase());
  }

  Future<bool> update(EnvironmentEntity environment) {
    return environmentProvider.update(
      environment.uid,
      environment.toDatabase(),
    );
  }

  Future<bool> delete(EnvironmentEntity environment) async {
    // Limpa todas as variáveis do ambiente.
    await variableProvider.clearByEnvironment(
      environment?.workspace?.uid,
      environment?.uid,
    );

    return environmentProvider.delete(environment?.uid);
  }

  Future<bool> clear(WorkspaceEntity workspace) async {
    // Pega todos os ambientes deste workspace.
    final environments = await all(workspace);
    // Para cada ambiente.
    for (final item in environments) {
      // Remove o ambiente.
      if (!await delete(item)) {
        return false;
      }
    }

    return true;
  }

  Future<EnvironmentEntity> active(WorkspaceEntity workspace) async {
    final data = await environmentProvider.active(workspace?.uid);
    return data == null || data.isEmpty
        ? EnvironmentEntity.none.copyWith(workspace: workspace)
        : EnvironmentEntity.fromDatabase(data);
  }

  static List<EnvironmentEntity> _mapDataToEnvironmentList(
    List<Map<String, dynamic>> data,
  ) {
    return data == null
        ? const []
        : [for (final item in data) EnvironmentEntity.fromDatabase(item)];
  }
}
