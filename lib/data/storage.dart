import 'package:sqflite/sqflite.dart';

class Storage implements Database {
  final Database database;

  Storage(this.database);

  @override
  Batch batch() => database.batch();

  @override
  Future<void> close() => database.close();

  @override
  Future<int> delete(
    String table, {
    String where,
    List whereArgs,
  }) {
    print('delete($table, where: $where, args: $whereArgs)');

    return database.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  @override
  Future<T> devInvokeMethod<T>(
    String method, [
    arguments,
  ]) {
    return null;
  }

  @override
  Future<T> devInvokeSqlMethod<T>(
    String method,
    String sql, [
    List arguments,
  ]) {
    return null;
  }

  @override
  Future<void> execute(
    String sql, [
    List arguments,
  ]) {
    print('execute(sql: $sql args: $arguments)');

    return database.execute(sql, arguments);
  }

  @override
  Future<int> getVersion() => database.getVersion();

  @override
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String nullColumnHack,
    ConflictAlgorithm conflictAlgorithm,
  }) {
    print('insert($table, values: $values)');

    return database.insert(
      table,
      values,
      nullColumnHack: nullColumnHack,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  @override
  bool get isOpen => database.isOpen;

  @override
  String get path => database.path;

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool distinct,
    List<String> columns,
    String where,
    List whereArgs,
    String groupBy,
    String having,
    String orderBy,
    int limit,
    int offset,
  }) {
    print('query($table, where: $where, args: $whereArgs)');

    return database.query(
      table,
      distinct: distinct,
      columns: columns,
      groupBy: groupBy,
      having: having,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      where: where,
      whereArgs: whereArgs,
    );
  }

  @override
  Future<int> rawDelete(
    String sql, [
    List arguments,
  ]) {
    print('delete(sql: $sql args: $arguments)');

    return database.rawDelete(sql, arguments);
  }

  @override
  Future<int> rawInsert(
    String sql, [
    List arguments,
  ]) {
    print('insert(sql: $sql args: $arguments)');

    return database.rawInsert(sql, arguments);
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List arguments,
  ]) {
    print('query(sql: $sql args: $arguments)');

    return database.rawQuery(sql, arguments);
  }

  @override
  Future<int> rawUpdate(
    String sql, [
    List arguments,
  ]) {
    print('update(sql: $sql, args: $arguments)');

    return database.rawUpdate(sql, arguments);
  }

  @override
  Future<void> setVersion(int version) {
    return database.setVersion(version);
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool exclusive,
  }) {
    return database.transaction<T>(action, exclusive: exclusive);
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String where,
    List whereArgs,
    ConflictAlgorithm conflictAlgorithm,
  }) {
    print('update($table, where: $where, args: $whereArgs, values: $values)');

    return database.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }
}
