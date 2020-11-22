import 'package:restler/data/migration.dart';
import 'package:sqflite/sqlite_api.dart';

class TwelveToThirteenMigration extends Migration {
  const TwelveToThirteenMigration() : super(12, 13);

  @override
  Future<void> migrate(Database database) async {
    await database.execute(
        "ALTER TABLE request ADD req_type TEXT NOT NULL DEFAULT 'rest'");
    await database.execute('ALTER TABLE request ADD req_target_data TEXT');
    await database.execute('ALTER TABLE request ADD req_data_data TEXT');
    await database
        .execute('ALTER TABLE request ADD req_notification_data TEXT');
  }
}
