import 'package:restler/data/migration.dart';
import 'package:sqflite/sqlite_api.dart';

class SevenToEightMigration extends Migration {
  const SevenToEightMigration() : super(7, 8);

  @override
  Future<void> migrate(Database database) async {
    await database.execute('ALTER TABLE proxy ADD pro_name TEXT');
    await database.execute('ALTER TABLE dns ADD dns_name TEXT');
  }
}
