import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:sqler/sqler.dart';

final folderTable = table('folder');
final folderUid = col('fol_uid');
final folderName = col('fol_name');
final folderParent = col('fol_parent');
final folderFavorite = col('fol_favorite');
final folderWorkspace = col('fol_workspace');

class FolderEntity extends Equatable {
  final String uid;
  final String name;
  final FolderEntity parent;
  final bool favorite;
  final WorkspaceEntity workspace;
  final int numberOfCalls;
  final int numberOfFolders;

  const FolderEntity({
    this.uid,
    this.name,
    this.parent,
    this.favorite = false,
    this.numberOfCalls = 0,
    this.numberOfFolders = 0,
    this.workspace = WorkspaceEntity.empty,
  });

  static const root = FolderEntity();

  factory FolderEntity.fromJson(Map<String, dynamic> json) {
    if (json == null || json['uid'] == null) {
      return root;
    } else {
      return FolderEntity(
        uid: json['uid'],
        name: json['name'],
        parent: FolderEntity.fromJson(json['parent']),
        favorite: json['favorite'],
        workspace: WorkspaceEntity.fromJson(json['workspace']),
      );
    }
  }

  bool get isRoot => uid == null;

  bool get insideRoot => parent?.uid == null;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'parent': parent?.toJson(),
      'favorite': favorite,
      'workspace': workspace?.toJson(),
    };
  }

  String path([String rootName]) {
    if (isRoot) {
      return rootName;
    } else if (parent == null) {
      return name;
    } else {
      return '${parent.path(rootName)} / $name';
    }
  }

  // Verifica se esta pasta é uma subpasta de [folder].
  bool isSubFolder(FolderEntity folder) {
    // Mesmo uid, então são a mesma pasta.
    if (uid == folder?.uid) {
      return false;
    }
    // Subpasta da pasta.
    if (parent?.uid == folder?.uid) {
      return true;
    }
    // Se tem pai, verificar se ele é subpasta.
    if (parent != null) {
      return parent.isSubFolder(folder);
    }
    return false;
  }

  // Verifica se esta pasta pode ser movida para [folder].
  bool canMoveTo(FolderEntity folder) {
    // Pasta raiz?
    if (folder?.uid == null) {
      return true;
    }
    // Mesma pasta não pode.
    if (folder.uid == uid) {
      return false;
    }
    // Também não pode mover para uma de suas sub-pastas.
    return !folder.isSubFolder(this);
  }

  Map<String, dynamic> toDatabase() {
    return {
      'fol_uid': uid,
      'fol_name': name,
      'fol_parent': parent?.uid,
      'fol_favorite': favorite ? 1 : 0,
      'fol_workspace': workspace?.uid,
    };
  }

  FolderEntity copyWith({
    String uid,
    String name,
    FolderEntity parent,
    bool favorite,
    int numberOfCalls,
    int numberOfFolders,
    WorkspaceEntity workspace,
  }) {
    return FolderEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      parent: parent ?? this.parent,
      favorite: favorite ?? this.favorite,
      workspace: workspace ?? this.workspace,
      numberOfCalls: numberOfCalls ?? this.numberOfCalls,
      numberOfFolders: numberOfFolders ?? this.numberOfFolders,
    );
  }

  @override
  String toString() {
    return 'Folder { uid: $uid, name: $name, parent: $parent, favorite: $favorite, workspace: $workspace }';
  }

  @override
  List get props => [uid, name, parent, favorite];
}
