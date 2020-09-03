import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:sqler/sqler.dart';

final certificateTable = table('certificate');
final certificateUid = col('cert_uid');
final certificateHost = col('cert_host');
final certificatePort = col('cert_port');
final certificatePfx = col('cert_pfx');
final certificateCrt = col('cert_crt');
final certificateKey = col('cert_key');
final certificatePassphrase = col('cert_passphrase');
final certificateEnabled = col('cert_enabled');
final certificateWorkspace = col('cert_workspace');

class CertificateEntity extends Equatable {
  final String uid;
  final String host;
  final int port;
  final String pfx;
  final String crt;
  final String key;
  final String passphrase;
  final bool enabled;
  final WorkspaceEntity workspace;

  const CertificateEntity({
    this.uid,
    this.host = '',
    this.port,
    this.pfx = '',
    this.crt = '',
    this.key = '',
    this.passphrase,
    this.enabled = true,
    this.workspace = WorkspaceEntity.empty,
  });

  static const empty = CertificateEntity();

  factory CertificateEntity.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return empty;
    } else {
      return CertificateEntity(
        uid: json['uid'],
        host: json['host'],
        port: json['port'],
        pfx: json['pfx'],
        crt: json['crt'],
        key: json['key'],
        passphrase: json['passphrase'],
        enabled: json['enabled'],
        workspace: WorkspaceEntity.fromJson(json['workspace']),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'host': host,
      'port': port,
      'pfx': pfx,
      'crt': crt,
      'key': key,
      'passphrase': passphrase,
      'enabled': enabled,
      'workspace': workspace?.toJson(),
    };
  }

  CertificateEntity.fromDatabase(Map<String, dynamic> db)
      : uid = db['cert_uid'],
        host = db['cert_host'],
        port = db['cert_port'],
        enabled = db['cert_enabled'] == 1,
        pfx = db['cert_pfx'],
        crt = db['cert_crt'],
        key = db['cert_key'],
        passphrase = db['cert_passphrase'],
        workspace = WorkspaceEntity.fromDatabase(db);

  Map<String, dynamic> toDatabase() {
    return {
      'cert_uid': uid,
      'cert_host': host,
      'cert_port': port,
      'cert_enabled': enabled ? 1 : 0,
      'cert_pfx': pfx,
      'cert_crt': crt,
      'cert_key': key,
      'cert_passphrase': passphrase,
      'cert_workspace': workspace?.uid,
    };
  }

  CertificateEntity copyWith({
    String uid,
    String host,
    int port,
    String pfx,
    String crt,
    String key,
    String passphrase,
    bool enabled,
    WorkspaceEntity workspace,
  }) {
    return CertificateEntity(
      uid: uid ?? this.uid,
      host: host ?? this.host,
      port: port ?? this.port,
      pfx: pfx ?? this.pfx,
      crt: crt ?? this.crt,
      key: key ?? this.key,
      passphrase: passphrase ?? this.passphrase,
      enabled: enabled ?? this.enabled,
      workspace: workspace ?? this.workspace,
    );
  }

  @override
  List<Object> get props => [
        uid,
        host,
        port,
        enabled,
        pfx,
        crt,
        key,
        passphrase,
        workspace,
      ];
}
