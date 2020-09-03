import 'package:restler/data/entities/dns_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';

abstract class DnsEvent {}

class DnsFetched extends DnsEvent {}

class SearchTextChanged extends DnsEvent {
  final String text;

  SearchTextChanged(this.text);
}

class SearchToggled extends DnsEvent {}

class DnsCreated extends DnsEvent {
  final DnsEntity dns;

  DnsCreated(this.dns);
}

class DnsEdited extends DnsEvent {
  final DnsEntity dns;

  DnsEdited(this.dns);
}

class DnsDuplicated extends DnsEvent {
  final DnsEntity dns;

  DnsDuplicated(this.dns);
}

class DnsDeleted extends DnsEvent {
  final DnsEntity dns;

  DnsDeleted(this.dns);
}

class DnsCleared extends DnsEvent {}

class DnsCopied extends DnsEvent {
  final DnsEntity dns;
  final WorkspaceEntity workspace;

  DnsCopied(this.dns, this.workspace);
}

class DnsMoved extends DnsEvent {
  final DnsEntity dns;
  final WorkspaceEntity workspace;

  DnsMoved(this.dns, this.workspace);
}
