import 'package:restler/data/entities/proxy_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';

abstract class ProxyEvent {}

class ProxyFetched extends ProxyEvent {}

class SearchTextChanged extends ProxyEvent {
  final String text;

  SearchTextChanged(this.text);
}

class SearchToggled extends ProxyEvent {}

class ProxyCreated extends ProxyEvent {
  final ProxyEntity proxy;

  ProxyCreated(this.proxy);
}

class ProxyEdited extends ProxyEvent {
  final ProxyEntity proxy;

  ProxyEdited(this.proxy);
}

class ProxyDuplicated extends ProxyEvent {
  final ProxyEntity proxy;

  ProxyDuplicated(this.proxy);
}

class ProxyDeleted extends ProxyEvent {
  final ProxyEntity proxy;

  ProxyDeleted(this.proxy);
}

class ProxyCleared extends ProxyEvent {}

class ProxyCopied extends ProxyEvent {
  final ProxyEntity proxy;
  final WorkspaceEntity workspace;

  ProxyCopied(this.proxy, this.workspace);
}

class ProxyMoved extends ProxyEvent {
  final ProxyEntity proxy;
  final WorkspaceEntity workspace;

  ProxyMoved(this.proxy, this.workspace);
}
