import 'package:restler/data/repositories/environment_repository.dart';
import 'package:restler/data/repositories/variable_repository.dart';
import 'package:restler/data/repositories/workspace_repository.dart';

class VariableLoader {
  final WorkspaceRepository workspaceRepository;
  final EnvironmentRepository environmentRepository;
  final VariableRepository variableRepository;

  const VariableLoader(
    this.workspaceRepository,
    this.environmentRepository,
    this.variableRepository,
  );

  Future<List<String>> load() async {
    final workspace = await workspaceRepository.active();
    final environment = await environmentRepository.active(workspace);
    final variables = [
      ...await variableRepository.global(workspace),
      ...await variableRepository.all(environment),
    ].map((item) => item.name).toSet().toList(growable: false);
    return variables;
  }
}
