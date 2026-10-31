part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class RegisterIdentityEvent extends NotificationsEvent {
  final String userId;

  const RegisterIdentityEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ClearIdentityEvent extends NotificationsEvent {
  const ClearIdentityEvent();
}

class RefreshPermissionEvent extends NotificationsEvent {
  const RefreshPermissionEvent();
}

class SetPushEnabledEvent extends NotificationsEvent {
  final bool enabled;
  const SetPushEnabledEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class PermissionChangedEvent extends NotificationsEvent {
  final NotificationPermission permission;
  const PermissionChangedEvent(this.permission);

  @override
  List<Object?> get props => [permission];
}

class SubscriptionChangedEvent extends NotificationsEvent {
  final bool optedIn;
  const SubscriptionChangedEvent(this.optedIn);

  @override
  List<Object?> get props => [optedIn];
}

class IncomingNotificationEvent extends NotificationsEvent {
  final IncomingNotification notification;
  const IncomingNotificationEvent(this.notification);

  @override
  List<Object?> get props => [notification];
}

class NotificationTappedEvent extends NotificationsEvent {
  const NotificationTappedEvent();
}

class MarkAllReadEvent extends NotificationsEvent {
  const MarkAllReadEvent();
}

enum NotificationChannel { push, email, sms }

class LoadNotificationPreferencesEvent extends NotificationsEvent {
  const LoadNotificationPreferencesEvent();
}

class SetNotificationPreferenceChannelEvent extends NotificationsEvent {
  final String category;
  final NotificationChannel channel;
  final bool enabled;

  const SetNotificationPreferenceChannelEvent({
    required this.category,
    required this.channel,
    required this.enabled,
  });

  @override
  List<Object?> get props => [category, channel, enabled];
}

class SaveNotificationPreferencesEvent extends NotificationsEvent {
  const SaveNotificationPreferencesEvent();
}
