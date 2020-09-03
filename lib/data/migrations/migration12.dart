import 'package:restler/data/migration.dart';
import 'package:sqflite/sqlite_api.dart';

class ElevenToTwelveMigration extends Migration {
  const ElevenToTwelveMigration() : super(11, 12);

  @override
  Future<void> migrate(Database database) async {
    await database
        .execute('ALTER TABLE variable ADD var_secret INTEGER DEFAULT 0');
  }
}
