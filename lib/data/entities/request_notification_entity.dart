import 'package:equatable/equatable.dart';
import 'package:restler/data/entities/notification_entity.dart';

class RequestNotificationEntity extends Equatable {
  final bool enabled;
  final List<NotificationEntity> notifications;

  static const empty = RequestNotificationEntity();

  const RequestNotificationEntity({
    this.notifications = const [],
    this.enabled = true,
  });

  factory RequestNotificationEntity.fromJson(Map<String, dynamic> json) {
    if (json == null || json.isEmpty) {
      return empty;
    } else {
      return RequestNotificationEntity(
        enabled: json['enabled'],
        notifications: (json['notifications'] as List)
            .map((item) => NotificationEntity.fromJson(item))
            .toList(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'notifications':
          notifications.map((notification) => notification.toJson()).toList()
    };
  }

  RequestNotificationEntity copyWith({
    List<NotificationEntity> notifications,
    bool enabled,
  }) {
    return RequestNotificationEntity(
      notifications: notifications ?? this.notifications,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List get props => [enabled, notifications];

  @override
  String toString() {
    return 'RequestNotification { enabled: $enabled, notification: $notifications }';
  }
}
