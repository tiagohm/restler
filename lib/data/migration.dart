import 'package:sqflite/sqflite.dart';

abstract class Migration {
  final int startVersion;
  final int endVersion;

  const Migration(this.startVersion, this.endVersion)
      : assert(startVersion != null),
        assert(endVersion != null),
        assert(startVersion >= 0),
        assert(startVersion < endVersion);

  Future<void> migrate(Database database);
}
