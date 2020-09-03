import 'package:restler/data/migration.dart';
import 'package:sqflite/sqlite_api.dart';

const _createWorkspaceTable = '''
CREATE TABLE workspace (
    ws_uid TEXT PRIMARY KEY,
    ws_name TEXT,
    ws_hidden INTEGER DEFAULT 0,
    ws_active INTEGER DEFAULT 0
);
''';

class NineToTenMigration extends Migration {
  const NineToTenMigration() : super(9, 10);

  @override
  Future<void> migrate(Database database) async {
    await database.execute(_createWorkspaceTable);
    await database.execute(
        'ALTER TABLE tab ADD tab_workspace TEXT REFERENCES workspace(ws_uid)');
    await database.execute(
        'ALTER TABLE folder ADD fol_workspace TEXT REFERENCES workspace(ws_uid)');
    await database.execute(
        'ALTER TABLE call ADD call_workspace TEXT REFERENCES workspace(ws_uid)');
    await database.execute(
        'ALTER TABLE cookie ADD cook_workspace TEXT REFERENCES workspace(ws_uid)');
    await database.execute(
        'ALTER TABLE certificate ADD cert_workspace TEXT REFERENCES workspace(ws_uid)');
    await database.execute(
        'ALTER TABLE proxy ADD pro_workspace TEXT REFERENCES workspace(ws_uid)');
    await database.execute(
        'ALTER TABLE dns ADD dns_workspace TEXT REFERENCES workspace(ws_uid)');
  }
}
