import 'package:restler/data/migration.dart';
import 'package:sqflite/sqlite_api.dart';

const _createCookieTable = '''
CREATE TABLE cookie (
	cook_uid TEXT PRIMARY KEY,
	cook_ts INTEGER DEFAULT 0,
	cook_enabled INTEGER DEFAULT 1,
	cook_domain TEXT,
	cook_path TEXT,
	cook_name TEXT,
	cook_value TEXT,
	cook_expires INTEGER,
	cook_max_age INTEGER,
	cook_secure INTEGER DEFAULT 0,
	cook_http_only INTEGER DEFAULT 0
);
''';

class OneToTwoMigration extends Migration {
  const OneToTwoMigration() : super(1, 2);

  @override
  Future<void> migrate(Database database) async {
    await database.execute(_createCookieTable);
  }
}
