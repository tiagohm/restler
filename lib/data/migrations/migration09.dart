import 'package:restler/data/migration.dart';
import 'package:sqflite/sqlite_api.dart';

class EightToNineMigration extends Migration {
  const EightToNineMigration() : super(8, 9);

  @override
  Future<void> migrate(Database database) async {
    await database.execute('ALTER TABLE request ADD req_description TEXT');
  }
}
