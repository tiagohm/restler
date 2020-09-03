import 'package:restler/data/migration.dart';
import 'package:sqflite/sqflite.dart';

const _createRequestTable = '''
CREATE TABLE request (
	req_uid TEXT PRIMARY KEY,
	req_scheme TEXT,
	req_method TEXT,
	req_url TEXT,
	req_body TEXT,
	req_query_data TEXT,
	req_header_data TEXT,
	req_auth TEXT
);
''';

const _createResponseTable = '''
CREATE TABLE response (
	resp_uid TEXT PRIMARY KEY,
	resp_status INTEGER,
	resp_time INTEGER,
	resp_content_type TEXT,
	resp_data TEXT,
	resp_headers TEXT,
	resp_cookies TEXT
);
''';

const _createHistoryTable = '''
CREATE TABLE history (
	his_uid TEXT PRIMARY KEY,
	his_date INTEGER,
	his_request TEXT,
	his_response TEXT,
	FOREIGN KEY(his_request) REFERENCES request(req_uid),
	FOREIGN KEY(his_response) REFERENCES response(resp_uid)
);
''';

const _createFolderTable = '''
CREATE TABLE folder (
	fol_uid TEXT PRIMARY KEY,
	fol_name TEXT,
	fol_parent TEXT,
	fol_favorite INTEGER DEFAULT 0,
	FOREIGN KEY(fol_parent) REFERENCES folder(fol_uid)
);
''';

const _createCallTable = '''
CREATE TABLE call (
	call_uid TEXT PRIMARY KEY,
	call_name TEXT,
	call_folder TEXT,
	call_request TEXT,
	call_favorite INTEGER DEFAULT 0,
	FOREIGN KEY(call_folder) REFERENCES folder(fol_uid),
	FOREIGN KEY(call_request) REFERENCES request(req_uid)
);
''';

class ZeroToOneMigration extends Migration {
  const ZeroToOneMigration() : super(0, 1);

  @override
  Future<void> migrate(Database database) async {
    await database.execute(_createRequestTable);
    await database.execute(_createResponseTable);
    await database.execute(_createHistoryTable);
    await database.execute(_createFolderTable);
    await database.execute(_createCallTable);
  }
}
