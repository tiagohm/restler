import 'package:restler/data/entities/certificate_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';

abstract class CertificateEvent {}

class CertificateFetched extends CertificateEvent {}

class SearchTextChanged extends CertificateEvent {
  final String text;

  SearchTextChanged(this.text);
}

class SearchToggled extends CertificateEvent {}

class CertificateCreated extends CertificateEvent {
  final CertificateEntity certificate;

  CertificateCreated(this.certificate);
}

class CertificateEdited extends CertificateEvent {
  final CertificateEntity certificate;

  CertificateEdited(this.certificate);
}

class CertificateDuplicated extends CertificateEvent {
  final CertificateEntity certificate;

  CertificateDuplicated(this.certificate);
}

class CertificateDeleted extends CertificateEvent {
  final CertificateEntity certificate;

  CertificateDeleted(this.certificate);
}

class CertificateCleared extends CertificateEvent {}

class CertificateCopied extends CertificateEvent {
  final CertificateEntity certificate;
  final WorkspaceEntity workspace;

  CertificateCopied(this.certificate, this.workspace);
}

class CertificateMoved extends CertificateEvent {
  final CertificateEntity certificate;
  final WorkspaceEntity workspace;

  CertificateMoved(this.certificate, this.workspace);
}
