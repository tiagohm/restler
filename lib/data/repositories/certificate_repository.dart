import 'package:restler/data/entities/certificate_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';
import 'package:restler/data/providers/certificate_provider.dart';

class CertificateRepository {
  final CertificateProvider certificateProvider;

  CertificateRepository(this.certificateProvider);

  Future<List<CertificateEntity>> all(WorkspaceEntity workspace) {
    return search(workspace, null);
  }

  Future<List<CertificateEntity>> search(
    WorkspaceEntity workspace,
    String text,
  ) async {
    final data = await certificateProvider.search(workspace?.uid, text);
    return [for (final item in data) CertificateEntity.fromDatabase(item)];
  }

  Future<CertificateEntity> get(String uid) async {
    if (uid == null) return null;
    final res = await certificateProvider.get(uid);
    return res != null || res.isNotEmpty
        ? CertificateEntity.fromDatabase(res)
        : null;
  }

  Future<bool> insert(CertificateEntity certificate) async {
    return certificateProvider.insert(certificate.toDatabase());
  }

  Future<bool> update(CertificateEntity certificate) async {
    return certificateProvider.update(
      certificate.uid,
      certificate.toDatabase(),
    );
  }

  Future<bool> delete(CertificateEntity certificate) async {
    return certificateProvider.delete(certificate.uid);
  }

  Future<bool> clear(WorkspaceEntity workspace) async {
    return certificateProvider.clear(workspace?.uid);
  }
}
