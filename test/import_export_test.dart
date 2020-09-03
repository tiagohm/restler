import 'package:flutter_test/flutter_test.dart';
import 'package:restler/data/entities/folder_entity.dart';
import 'package:restler/services/import_export.dart';

const a = FolderEntity(
  uid: '1',
  name: 'GitHub',
  parent: FolderEntity.root,
  favorite: true,
);

const b = FolderEntity(
  uid: '2',
  name: 'GitLab',
  parent: a,
);

const c = FolderEntity(
  uid: '3',
  name: 'restler',
  parent: b,
);

const d = FolderEntity(
  uid: '4',
  name: 'SWAPI',
  parent: FolderEntity.root,
);

const folders = [c, b, a, d];

void main() {
  test('Sort folders', () {
    final sortedFolders = sortFolders(folders);

    print(sortedFolders);

    expect(sortedFolders[0], a);
    expect(sortedFolders[1], d);
    expect(sortedFolders[2], b);
    expect(sortedFolders[3], c);
  });
}
