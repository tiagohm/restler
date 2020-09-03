import 'package:restler/data/migration.dart';
import 'package:sqflite/sqlite_api.dart';

const _createDnsTable = '''
CREATE TABLE dns (
    dns_uid TEXT PRIMARY KEY,
    dns_address TEXT,
    dns_url TEXT,
    dns_port INTEGER,
    dns_https INTEGER DEFAULT 1,
    dns_enabled INTEGER DEFAULT 1
);
''';

class SixToSevenMigration extends Migration {
  const SixToSevenMigration() : super(6, 7);

  @override
  Future<void> migrate(Database database) async {
    await database.execute(_createDnsTable);
    await database.execute('ALTER TABLE response ADD resp_redirects TEXT');
  }
}
