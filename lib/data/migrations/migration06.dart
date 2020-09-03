import 'package:restler/data/migration.dart';
import 'package:sqflite/sqlite_api.dart';

const _createProxyTable = '''
CREATE TABLE proxy (
    pro_uid TEXT PRIMARY KEY,
    pro_host TEXT,
    pro_port INTEGER,
    pro_http INTEGER DEFAULT 1,
    pro_https INTEGER DEFAULT 1,
    pro_auth INTEGER DEFAULT 1,
    pro_username TEXT,
    pro_password TEXT,
    pro_enabled INTEGER DEFAULT 1
);
''';

class FiveToSixMigration extends Migration {
  const FiveToSixMigration() : super(5, 6);

  @override
  Future<void> migrate(Database database) async {
    await database.execute(_createProxyTable);
    await database.execute('ALTER TABLE request ADD req_settings TEXT');
  }
}
