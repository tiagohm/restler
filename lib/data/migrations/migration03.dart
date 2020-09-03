import 'package:restler/data/migration.dart';
import 'package:sqflite/sqlite_api.dart';

class TwoToThreeMigration extends Migration {
  const TwoToThreeMigration() : super(2, 3);

  @override
  Future<void> migrate(Database database) async {
    await database
        .execute('ALTER TABLE response ADD resp_data_size INTEGER DEFAULT 0');
  }
}
