import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:restio/restio.dart';
import 'package:restler/data/entities/call_entity.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/data/entities/request_auth_entity.dart';
import 'package:restler/data/entities/request_body_entity.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/services/import_export.dart';

void main() {
  ImportExportData insomnia;
  final insomniaFile = File('./test/assets/insomnia.json');

  CallEntity obtainCallByName(String name) {
    return insomnia.requests.where((item) => item.name == name).first;
  }

  RequestEntity obtainRequestByName(String name) {
    return obtainCallByName(name)?.request;
  }

  setUp(() {
    final insomniaText = insomniaFile.readAsStringSync();
    insomnia =
        Importer.insomnia(WorkspaceEntity.empty).importFromText(insomniaText);
  });

  test('No Body', () {
    final request = obtainRequestByName('No Body');
    expect(request.body, RequestBodyEntity.empty);
  });

  test('File Body Is Empty', () {
    final request = obtainRequestByName('File Body Is Empty');
    expect(request.body.enabled, true);
    expect(request.body.type, RequestBodyType.file);
    expect(request.body.file, isEmpty);
  });

  test('File Body With Image', () {
    final request = obtainRequestByName('File Body With Image');
    expect(request.body.enabled, true);
    expect(request.body.type, RequestBodyType.file);
    expect(request.body.file, '/home/tiagohm/Imagens/me.jpg');
  });

  test('Text Body Is Empty', () {
    final request = obtainRequestByName('Text Body Is Empty');
    expect(request.body.enabled, true);
    expect(request.body.type, RequestBodyType.text);
    expect(request.body.text, isEmpty);
  });

  test('Text Body With Plain Text', () {
    final request = obtainRequestByName('Text Body With Plain Text');
    expect(request.body.enabled, true);
    expect(request.body.type, RequestBodyType.text);
    expect(request.body.text, 'I love Giovanna');
  });

  test('Text Body With XML Text', () {
    final request = obtainRequestByName('Text Body With XML Text');
    expect(request.body.enabled, true);
    expect(request.body.type, RequestBodyType.text);
    expect(request.body.text, '''
<note>
  <to>Giovanna</to>
  <from>Tiago</from>
  <heading>Reminder</heading>
  <body>I love you!</body>
</note>''');
    expect(request.header.headers.first.name, 'Content-Type');
    expect(request.header.headers.first.value, 'application/xml');
  });

  test('Text Body With JSON Text', () {
    final request = obtainRequestByName('Text Body With JSON Text');
    expect(request.body.enabled, true);
    expect(request.body.type, RequestBodyType.text);
    expect(request.body.text,
        '{"to": "Giovanna", "from": "Tiago", "heading":"Reminder","body":"I love you!"}');
    expect(request.header.headers.first.name, 'Content-Type');
    expect(request.header.headers.first.value, 'application/json');
  });

  test('Form Body Is Empty', () {
    final request = obtainRequestByName('Form Body Is Empty');
    expect(request.body.enabled, true);
    expect(request.body.type, RequestBodyType.form);
    expect(request.body.formItems, isEmpty);
  });

  test('Form Body With Items', () {
    final request = obtainRequestByName('Form Body With Items');
    expect(request.body.enabled, true);
    expect(request.body.type, RequestBodyType.form);
    expect(request.body.formItems.length, 4);
    expect(request.body.formItems[0].name, 'foo');
    expect(request.body.formItems[0].value, 'bar');
    expect(request.body.formItems[0].enabled, true);
    expect(request.body.formItems[1].name, isEmpty);
    expect(request.body.formItems[1].value, 'bar');
    expect(request.body.formItems[1].enabled, true);
    expect(request.body.formItems[2].name, 'foo');
    expect(request.body.formItems[2].value, 'bar');
    expect(request.body.formItems[2].enabled, false);
    expect(request.body.formItems[3].name, 'foo');
    expect(request.body.formItems[3].value, isEmpty);
    expect(request.body.formItems[3].enabled, true);
  });

  test('Multipart Body Is Empty', () {
    final request = obtainRequestByName('Multipart Body Is Empty');
    expect(request.body.enabled, true);
    expect(request.body.type, RequestBodyType.multipart);
    expect(request.body.multipartItems, isEmpty);
  });

  test('Multipart Body With Text Items', () {
    final request = obtainRequestByName('Multipart Body With Text Items');
    expect(request.body.enabled, true);
    expect(request.body.type, RequestBodyType.multipart);
    expect(request.body.multipartItems.length, 4);
    expect(request.body.multipartItems[0].name, 'foo');
    expect(request.body.multipartItems[0].value, 'bar');
    expect(request.body.multipartItems[0].enabled, true);
    expect(request.body.multipartItems[1].name, isEmpty);
    expect(request.body.multipartItems[1].value, 'bar');
    expect(request.body.multipartItems[1].enabled, true);
    expect(request.body.multipartItems[2].name, 'foo');
    expect(request.body.multipartItems[2].value, 'bar');
    expect(request.body.multipartItems[2].enabled, false);
    expect(request.body.multipartItems[3].name, 'foo');
    expect(request.body.multipartItems[3].value, isEmpty);
    expect(request.body.multipartItems[3].enabled, true);
  });

  test('Multipart Body With File Items', () {
    final request = obtainRequestByName('Multipart Body With File Items');
    expect(request.body.enabled, true);
    expect(request.body.type, RequestBodyType.multipart);
    expect(request.body.multipartItems.length, 4);
    expect(request.body.multipartItems[0].name, 'foo');
    expect(request.body.multipartItems[0].file.path,
        '/home/tiagohm/Imagens/me.jpg');
    expect(request.body.multipartItems[0].enabled, true);
    expect(request.body.multipartItems[1].name, isEmpty);
    expect(request.body.multipartItems[1].file.path,
        '/home/tiagohm/Imagens/me.jpg');
    expect(request.body.multipartItems[1].enabled, true);
    expect(request.body.multipartItems[2].name, 'foo');
    expect(request.body.multipartItems[2].file.path,
        '/home/tiagohm/Imagens/me.jpg');
    expect(request.body.multipartItems[2].enabled, false);
    expect(request.body.multipartItems[3].name, 'foo');
    expect(request.body.multipartItems[3].file.path, isEmpty);
    expect(request.body.multipartItems[3].enabled, true);
  });

  test('Multipart Body With Text And File Items', () {
    final request =
        obtainRequestByName('Multipart Body With Text And File Items');
    expect(request.body.enabled, true);
    expect(request.body.type, RequestBodyType.multipart);
    expect(request.body.multipartItems[0].name, 'foo');
    expect(request.body.multipartItems[0].value, 'bar');
    expect(request.body.multipartItems[0].enabled, true);
    expect(request.body.multipartItems[1].name, 'foo');
    expect(request.body.multipartItems[1].file.path,
        '/home/tiagohm/Imagens/me.jpg');
    expect(request.body.multipartItems[1].enabled, true);
  });

  test('Query Is Empty', () {
    final request = obtainRequestByName('Query Is Empty');
    expect(request.query.enabled, true);
    expect(request.query.queries, isEmpty);
  });

  test('Query With Items', () {
    final request = obtainRequestByName('Query With Items');
    expect(request.query.enabled, true);
    expect(request.query.queries.length, 4);
    expect(request.query.queries[0].name, 'foo');
    expect(request.query.queries[0].value, 'bar');
    expect(request.query.queries[0].enabled, true);
    expect(request.query.queries[1].name, isEmpty);
    expect(request.query.queries[1].value, 'bar');
    expect(request.query.queries[1].enabled, true);
    expect(request.query.queries[2].name, 'foo');
    expect(request.query.queries[2].value, 'bar');
    expect(request.query.queries[2].enabled, false);
    expect(request.query.queries[3].name, 'foo');
    expect(request.query.queries[3].value, isEmpty);
    expect(request.query.queries[3].enabled, true);
  });

  test('Query From URL', () {
    final request = obtainRequestByName('Query From URL');
    expect(request.query.enabled, true);
    expect(request.query.queries.length, 1);
    expect(request.query.queries[0].name, 'format');
    expect(request.query.queries[0].value, 'wookiee');
    expect(request.query.queries[0].enabled, true);
  });

  test('Header Is Empty', () {
    final request = obtainRequestByName('Header Is Empty');
    expect(request.header.enabled, true);
    expect(request.header.headers, isEmpty);
  });

  test('Header With Items', () {
    final request = obtainRequestByName('Header With Items');
    expect(request.header.enabled, true);
    expect(request.header.headers.length, 4);
    expect(request.header.headers[0].name, 'foo');
    expect(request.header.headers[0].value, 'bar');
    expect(request.header.headers[0].enabled, true);
    expect(request.header.headers[1].name, isEmpty);
    expect(request.header.headers[1].value, 'bar');
    expect(request.header.headers[1].enabled, true);
    expect(request.header.headers[2].name, 'foo');
    expect(request.header.headers[2].value, 'bar');
    expect(request.header.headers[2].enabled, false);
    expect(request.header.headers[3].name, 'foo');
    expect(request.header.headers[3].value, isEmpty);
    expect(request.header.headers[3].enabled, true);
  });

  test('No Auth', () {
    final request = obtainRequestByName('No Auth');
    expect(request.auth, RequestAuthEntity.empty);
  });

  test('Basic Auth', () {
    final request = obtainRequestByName('Basic Auth');
    expect(request.auth.enabled, true);
    expect(request.auth.type, RequestAuthType.basic);
    expect(request.auth.basicUsername, 'username');
    expect(request.auth.basicPassword, 'password');
  });

  test('Basic Auth Is Disabled', () {
    final request = obtainRequestByName('Basic Auth Is Disabled');
    expect(request.auth.enabled, false);
    expect(request.auth.type, RequestAuthType.basic);
    expect(request.auth.basicUsername, 'username');
    expect(request.auth.basicPassword, 'password');
  });

  test('Digest Auth', () {
    final request = obtainRequestByName('Digest Auth');
    expect(request.auth.enabled, true);
    expect(request.auth.type, RequestAuthType.digest);
    expect(request.auth.digestUsername, 'username');
    expect(request.auth.digestPassword, 'password');
  });

  test('Bearer Auth', () {
    final request = obtainRequestByName('Bearer Auth');
    expect(request.auth.enabled, true);
    expect(request.auth.type, RequestAuthType.bearer);
    expect(request.auth.bearerPrefix, 'Bearer');
    expect(request.auth.bearerToken, 'Giovanna');
  });

  test('Header API Key Is Bearer Auth', () {
    final request = obtainRequestByName('Header API Key Is Bearer Auth');
    expect(request.auth.enabled, true);
    expect(request.auth.type, RequestAuthType.bearer);
    expect(request.auth.bearerPrefix, '123456789');
    expect(request.auth.bearerToken, 'Token');
  });

  test('Query API Key', () {
    final request = obtainRequestByName('Query API Key');
    expect(request.auth, RequestAuthEntity.empty);
    expect(request.query.enabled, true);
    expect(request.query.queries.length, 1);
    expect(request.query.queries[0].enabled, true);
    expect(request.query.queries[0].name, 'api_key');
    expect(request.query.queries[0].value, '123456789');
  });

  test('Hawk Auth SHA1', () {
    final request = obtainRequestByName('Hawk Auth SHA1');
    expect(request.auth.enabled, true);
    expect(request.auth.type, RequestAuthType.hawk);
    expect(request.auth.hawkId, 'id');
    expect(request.auth.hawkKey, 'key');
    expect(request.auth.hawkExt, 'ext');
    expect(request.auth.hawkAlgorithm, HawkAlgorithm.sha1);
  });

  test('Hawk Auth SHA256', () {
    final request = obtainRequestByName('Hawk Auth SHA256');
    expect(request.auth.enabled, true);
    expect(request.auth.type, RequestAuthType.hawk);
    expect(request.auth.hawkId, 'id');
    expect(request.auth.hawkKey, 'key');
    expect(request.auth.hawkExt, 'ext');
    expect(request.auth.hawkAlgorithm, HawkAlgorithm.sha256);
  });

  test('Custom Method', () {
    final request = obtainRequestByName('Custom Method');
    expect(request.method, 'GIOVANNA');
  });

  test('URL Is An IPv4', () {
    final request = obtainRequestByName('URL Is An IPv4');
    final uri = RequestUri.parse(request.rightUrl);
    expect(uri.scheme, 'https');
    expect(uri.host, '104.31.76.248');
    expect(uri.port, '443');
    expect(uri.paths, const ['api', 'planets']);
  });

  test('URL Is An IPv6', () {
    final request = obtainRequestByName('URL Is An IPv6');
    final uri = RequestUri.parse(request.rightUrl);
    expect(uri.scheme, 'https');
    expect(uri.host, '[2001:4860:4860::8888]');
    expect(uri.port, '443');
    expect(uri.paths, isEmpty);
  });

  test('URL Contains Chinese Chars', () {
    final request = obtainRequestByName('URL Contains Chinese Chars');
    final uri = RequestUri.parse(request.rightUrl);
    expect(uri.scheme, 'http');
    expect(uri.host, '見.香港');
    expect(uri.port, isNull);
    expect(uri.paths, const ['']);
  });

  test('URL Contains Encoded Chinese Chars', () {
    final request = obtainRequestByName('URL Contains Encoded Chinese Chars');
    final uri = RequestUri.parse(request.rightUrl);
    expect(uri.scheme, 'http');
    expect(uri.host, 'xn--nw2a.xn--j6w193g');
    expect(uri.port, isNull);
    expect(uri.paths, const ['']);
  });

  test('URL Is Empty', () {
    final request = obtainRequestByName('URL Is Empty');
    expect(request.url, 'http://');
    expect(request.rightUrl, 'http://');
  });

  test('URL Parts Are Variables', () {
    final request = obtainRequestByName('URL Parts Are Variables');
    final uri = RequestUri.parse(request.url);
    expect(uri.scheme, '{{scheme}}');
    expect(uri.host, '{{host}}');
    expect(uri.port, '{{port}}');
    expect(uri.paths, ['{{path}}']);
    expect(request.query.queries[0].name, '{{qn0}}');
    expect(request.query.queries[0].value, '{{qv0}}');
  });

  test('URL Is Https', () {
    final request = obtainRequestByName('URL Is Https');
    final uri = RequestUri.parse(request.rightUrl);
    expect(uri.scheme, 'https');
  });

  test('URL Is Http', () {
    final request = obtainRequestByName('URL Is Http');
    final uri = RequestUri.parse(request.rightUrl);
    expect(uri.scheme, 'http');
  });

  test('URL Has No Scheme', () {
    final request = obtainRequestByName('URL Has No Scheme');
    final uri = RequestUri.parse(request.rightUrl);
    expect(uri.scheme, 'http');
    expect(uri.host, 'localhost');
    expect(uri.port, '8080');
  });

  test('Request Description', () {
    final request = obtainRequestByName('Request Description');
    expect(request.description,
        'This is a request description that supports **Markdown**!');
  });

  test('Request Settings Are All False', () {
    final request = obtainRequestByName('Request Settings Are All False');
    expect(request.settings.sendCookies, false);
    expect(request.settings.storeCookies, false);
  });

  test('Inside A Folder', () {
    final call = obtainCallByName('Inside A Folder');
    expect(call.folder.name, 'A');
    expect(call.folder.parent, FolderEntity.root);
    expect(call.workspace, insomnia.workspaces[0]);
  });

  test('Cookies', () {
    expect(insomnia.cookies.length, 1);
    expect(insomnia.cookies[0].name, '__cfduid');
    expect(insomnia.cookies[0].domain, 'swapi.co');
    expect(insomnia.cookies[0].httpOnly, true);
    expect(insomnia.cookies[0].path, '/');
    expect(insomnia.cookies[0].secure, true);
    expect(insomnia.cookies[0].value,
        'd2b77bb2ada17578b051ab25dcb0384841585223622');
  });

  test('Workspace', () {
    expect(insomnia.workspaces.length, 1);
    expect(insomnia.workspaces[0].name, 'Insomnia');

    final call = obtainCallByName('No Body');

    expect(call.workspace, insomnia.workspaces[0]);
  });

  test('Environments', () {
    expect(insomnia.environments.length, 2);
    expect(insomnia.environments[0].name, 'dev');
    expect(insomnia.environments[0].workspace, insomnia.workspaces[0]);
    expect(insomnia.environments[1].name, 'hml');
    expect(insomnia.environments[1].workspace, insomnia.workspaces[0]);
  });

  test('Variables', () {
    expect(insomnia.variables.length, 15);
    expect(insomnia.variables[0].name, 'person.name');
    expect(insomnia.variables[0].environment.isGlobal, true);
    expect(insomnia.variables[0].workspace, insomnia.workspaces[0]);
    expect(insomnia.variables[0].value, 'giovanna');

    expect(insomnia.variables[3].name, 'person.name');
    expect(insomnia.variables[3].environment, insomnia.environments[0]);
    expect(insomnia.variables[3].workspace, insomnia.workspaces[0]);
    expect(insomnia.variables[3].value, 'tiago');

    expect(insomnia.variables[10].name, 'person.name');
    expect(insomnia.variables[10].environment, insomnia.environments[1]);
    expect(insomnia.variables[10].workspace, insomnia.workspaces[0]);
    expect(insomnia.variables[10].value, 'tiago');
  });
}
