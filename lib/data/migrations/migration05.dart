import 'package:restler/data/migration.dart';
import 'package:sqflite/sqlite_api.dart';

const _createCertificateTable = '''
CREATE TABLE certificate (
    cert_uid TEXT PRIMARY KEY,
    cert_host TEXT,
    cert_port INTEGER,
    cert_pfx TEXT,
    cert_crt TEXT,
    cert_key TEXT,
    cert_passphrase TEXT,
    cert_enabled INTEGER DEFAULT 1
);
''';

class FourToFiveMigration extends Migration {
  const FourToFiveMigration() : super(4, 5);

  @override
  Future<void> migrate(Database database) async {
    await database.execute(_createCertificateTable);
  }
}
