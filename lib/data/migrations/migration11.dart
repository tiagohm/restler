import 'package:restler/data/migration.dart';
import 'package:sqflite/sqlite_api.dart';

const _createEnvironmentTable = '''
CREATE TABLE environment (
    env_uid TEXT PRIMARY KEY,
    env_name TEXT,
    env_enabled INTEGER DEFAULT 1,
    env_active INTEGER DEFAULT 0,
    env_workspace TEXT REFERENCES workspace(ws_uid)
);
''';

const _createVariableTable = '''
CREATE TABLE variable (
    var_uid TEXT PRIMARY KEY,
    var_name TEXT,
    var_value TEXT,
    var_enabled INTEGER DEFAULT 1,
    var_environment TEXT REFERENCES environment(env_uid),
    var_workspace TEXT REFERENCES workspace(ws_uid)
);
''';

class TenToElevenMigration extends Migration {
  const TenToElevenMigration() : super(10, 11);

  @override
  Future<void> migrate(Database database) async {
    await database.execute(_createEnvironmentTable);
    await database.execute(_createVariableTable);
  }
}
