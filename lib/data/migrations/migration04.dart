import 'package:restler/data/migration.dart';
import 'package:sqflite/sqlite_api.dart';

const _createTabTable = '''
CREATE TABLE tab (
    tab_uid TEXT PRIMARY KEY,
    tab_name TEXT,
    tab_call TEXT,
    tab_request TEXT,
    tab_saved INTEGER DEFAULT 0,
    tab_opened_at INTEGER,
    tab_favorited INTEGER DEFAULT 0,
    tab_hidden INTEGER DEFAULT 0,
    tab_position INTEGER DEFAULT 0,
    FOREIGN KEY(tab_call) REFERENCES call(call_uid),
    FOREIGN KEY(tab_request) REFERENCES request(req_uid)
);
''';

class ThreeToFourMigration extends Migration {
  const ThreeToFourMigration() : super(3, 4);

  @override
  Future<void> migrate(Database database) async {
    await database.execute(_createTabTable);
  }
}
