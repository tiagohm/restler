import 'package:restio/restio.dart';
import 'package:restler/data/entities/data_entity.dart';
import 'package:restler/data/entities/form_entity.dart';
import 'package:restler/data/entities/header_entity.dart';
import 'package:restler/data/entities/multipart_entity.dart';
import 'package:restler/data/entities/notification_entity.dart';
import 'package:restler/data/entities/query_entity.dart';
import 'package:restler/data/entities/request_auth_entity.dart';
import 'package:restler/data/entities/request_body_entity.dart';
import 'package:restler/data/entities/request_entity.dart';
import 'package:restler/data/entities/request_settings_entity.dart';
import 'package:restler/data/entities/target_entity.dart';

abstract class RequestEvent {}

class RequestLoaded extends RequestEvent {
  final RequestEntity request;

  RequestLoaded(this.request);
}

class RequestCleared extends RequestEvent {}

class TypeChanged extends RequestEvent {
  final String type;

  TypeChanged(this.type);
}

class MethodChanged extends RequestEvent {
  final String method;

  MethodChanged(this.method);
}

class SchemeChanged extends RequestEvent {
  final String scheme;

  SchemeChanged(this.scheme);
}

class UrlChanged extends RequestEvent {
  final String url;

  UrlChanged(this.url);
}

class DescriptionChanged extends RequestEvent {
  final String description;

  DescriptionChanged(this.description);
}

class BodyEnabled extends RequestEvent {
  final bool enabled;

  BodyEnabled({
    this.enabled,
  });
}

class DataEnabled extends RequestEvent {
  final bool enabled;

  DataEnabled({
    this.enabled,
  });
}

class NotificationEnabled extends RequestEvent {
  final bool enabled;

  NotificationEnabled({
    this.enabled,
  });
}

class QueryEnabled extends RequestEvent {
  final bool enabled;

  QueryEnabled({
    this.enabled,
  });
}

class HeaderEnabled extends RequestEvent {
  final bool enabled;

  HeaderEnabled({
    this.enabled,
  });
}

// Body.

class BodyTypeChanged extends RequestEvent {
  final RequestBodyType type;

  BodyTypeChanged(this.type);
}

class FormAdded extends RequestEvent {}

class FormEdited extends RequestEvent {
  final FormEntity form;

  FormEdited(this.form);
}

class FormDeleted extends RequestEvent {
  final FormEntity form;

  FormDeleted(this.form);
}

class FormDuplicated extends RequestEvent {
  final FormEntity form;

  FormDuplicated(this.form);
}

class MultipartAdded extends RequestEvent {}

class MultipartEdited extends RequestEvent {
  final MultipartEntity multipart;

  MultipartEdited(this.multipart);
}

class MultipartDeleted extends RequestEvent {
  final MultipartEntity multipart;

  MultipartDeleted(this.multipart);
}

class MultipartDuplicated extends RequestEvent {
  final MultipartEntity multipart;

  MultipartDuplicated(this.multipart);
}

class TextEdited extends RequestEvent {
  final String text;

  TextEdited(this.text);
}

class TextContentTypeChanged extends RequestEvent {
  final String contentType;

  TextContentTypeChanged(this.contentType);
}

class FileChoosed extends RequestEvent {
  final String file;

  FileChoosed(this.file);
}

class FileRemoved extends RequestEvent {}

// Target.

class TargetAdded extends RequestEvent {}

class TargetEdited extends RequestEvent {
  final TargetEntity target;

  TargetEdited(this.target);
}

class TargetDeleted extends RequestEvent {
  final TargetEntity target;

  TargetDeleted(this.target);
}

class TargetDuplicated extends RequestEvent {
  final TargetEntity target;

  TargetDuplicated(this.target);
}

// Data.

class DataAdded extends RequestEvent {}

class DataEdited extends RequestEvent {
  final DataEntity data;

  DataEdited(this.data);
}

class DataDeleted extends RequestEvent {
  final DataEntity data;

  DataDeleted(this.data);
}

class DataDuplicated extends RequestEvent {
  final DataEntity data;

  DataDuplicated(this.data);
}

// Notification.

class NotificationAdded extends RequestEvent {}

class NotificationEdited extends RequestEvent {
  final NotificationEntity notification;

  NotificationEdited(this.notification);
}

class NotificationDeleted extends RequestEvent {
  final NotificationEntity notification;

  NotificationDeleted(this.notification);
}

class NotificationDuplicated extends RequestEvent {
  final NotificationEntity notification;

  NotificationDuplicated(this.notification);
}

// Query.

class QueryAdded extends RequestEvent {}

class QueryEdited extends RequestEvent {
  final QueryEntity query;

  QueryEdited(this.query);
}

class QueryDeleted extends RequestEvent {
  final QueryEntity query;

  QueryDeleted(this.query);
}

class QueryDuplicated extends RequestEvent {
  final QueryEntity query;

  QueryDuplicated(this.query);
}

// Header.

class HeaderAdded extends RequestEvent {}

class HeaderEdited extends RequestEvent {
  final HeaderEntity header;

  HeaderEdited(this.header);
}

class HeaderDeleted extends RequestEvent {
  final HeaderEntity header;

  HeaderDeleted(this.header);
}

class HeaderDuplicated extends RequestEvent {
  final HeaderEntity header;

  HeaderDuplicated(this.header);
}

class AuthEdited extends RequestEvent {
  final RequestAuthType type;
  final bool enabled;
  final String basicUsername;
  final String basicPassword;
  final String bearerToken;
  final String bearerPrefix;
  final String hawkId;
  final String hawkKey;
  final String hawkExt;
  final HawkAlgorithm hawkAlgorithm;
  final String digestUsername;
  final String digestPassword;

  AuthEdited({
    this.type,
    this.enabled,
    this.basicUsername,
    this.basicPassword,
    this.bearerToken,
    this.bearerPrefix,
    this.hawkId,
    this.hawkKey,
    this.hawkExt,
    this.hawkAlgorithm,
    this.digestUsername,
    this.digestPassword,
  });
}

class RequestSent extends RequestEvent {}

class RequestStopped extends RequestEvent {}

class RequestSettingsEdited extends RequestEvent {
  final RequestSettingsEntity settings;

  RequestSettingsEdited(this.settings);
}
