import 'package:restler/data/entities/environment_entity.dart';
import 'package:restler/data/entities/variable_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/providers/variable_provider.dart';

class VariableRepository {
  final VariableProvider variableProvider;

  VariableRepository(this.variableProvider);

  Future<List<VariableEntity>> all(EnvironmentEntity environment) async {
    final data = await variableProvider.all(
      environment.workspace?.uid,
      environment.uid,
    );

    return _mapDataToVariableList(data);
  }

  Future<List<VariableEntity>> global(WorkspaceEntity workspace) async {
    final data = await variableProvider.all(workspace?.uid, null);
    return _mapDataToVariableList(data);
  }

  Future<List<VariableEntity>> search(
    EnvironmentEntity environment, {
    String text = '',
    bool enabled,
  }) async {
    final data = await variableProvider.search(
      environment?.workspace?.uid,
      environment?.uid,
      text: text,
    );

    return _mapDataToVariableList(data);
  }

  Future<VariableEntity> get(String uid) async {
    final data = await variableProvider.get(uid);
    return data == null || data.isEmpty
        ? null
        : VariableEntity.fromDatabase(data);
  }

  Future<bool> insert(VariableEntity variable) {
    return variableProvider.insert(variable.toDatabase());
  }

  Future<bool> update(VariableEntity variable) {
    return variableProvider.update(
      variable.uid,
      variable.toDatabase(),
    );
  }

  Future<bool> delete(VariableEntity variable) {
    return variableProvider.delete(variable?.uid);
  }

  Future<bool> clearByWorkspace(WorkspaceEntity workspace) {
    return variableProvider.clearByWorkspace(workspace?.uid);
  }

  Future<bool> clearByEnvironment(EnvironmentEntity environment) {
    return variableProvider.clearByEnvironment(
      environment?.workspace?.uid,
      environment?.uid,
    );
  }

  static List<VariableEntity> _mapDataToVariableList(
    List<Map<String, dynamic>> data,
  ) {
    return data == null
        ? const []
        : [for (final item in data) VariableEntity.fromDatabase(item)];
  }
}
