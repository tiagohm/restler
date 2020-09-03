import 'package:restler/data/entities/cookie_entity.dart';
import 'package:restler/data/entities/workspace_entity.dart';

abstract class CookieEvent {}

class CookieFetched extends CookieEvent {}

class SearchTextChanged extends CookieEvent {
  final String text;

  SearchTextChanged(this.text);
}

class SearchToggled extends CookieEvent {}

class CookieCreated extends CookieEvent {
  final CookieEntity cookie;

  CookieCreated(this.cookie);
}

class CookieEdited extends CookieEvent {
  final CookieEntity cookie;

  CookieEdited(this.cookie);
}

class CookieDuplicated extends CookieEvent {
  final CookieEntity cookie;

  CookieDuplicated(this.cookie);
}

class CookieDeleted extends CookieEvent {
  final CookieEntity cookie;

  CookieDeleted(this.cookie);
}

class CookieCleared extends CookieEvent {}

class CookieCopied extends CookieEvent {
  final CookieEntity cookie;
  final WorkspaceEntity workspace;

  CookieCopied(this.cookie, this.workspace);
}

class CookieMoved extends CookieEvent {
  final CookieEntity cookie;
  final WorkspaceEntity workspace;

  CookieMoved(this.cookie, this.workspace);
}
