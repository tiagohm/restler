import 'package:flutter/foundation.dart';
import 'package:restler/data/migration.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> openDatabaseWithMigration({
  @required String name,
  @required int version,
  List<Migration> migrations,
  bool readOnly = false,
}) async {
  final path = name != null
      ? join(await getDatabasesPath(), name)
      : inMemoryDatabasePath;

  print('Opening database at $path...');

  return openDatabase(
    path,
    version: version ?? 1,
    onUpgrade: (database, startVersion, endVersion) async {
      await _runMigrations(
        database,
        startVersion,
        endVersion,
        migrations,
      );
    },
    readOnly: readOnly ?? false,
  );
}

Future<void> _runMigrations(
  final Database database,
  final int startVersion,
  final int endVersion,
  final List<Migration> migrations,
) async {
  final relevantMigrations = migrations
      .where((migration) => migration.startVersion >= startVersion)
      .toList()
        ..sort((first, second) =>
            first.startVersion.compareTo(second.startVersion));

  if (relevantMigrations.isEmpty ||
      relevantMigrations.last.endVersion != endVersion) {
    throw StateError(
      'There is no migration supplied to update the database to the current version.'
      ' Aborting the migration.',
    );
  }

  for (final m in relevantMigrations) {
    print('Migrating database from ${m.startVersion} to ${m.endVersion}...');
    await m.migrate(database);
  }
}
