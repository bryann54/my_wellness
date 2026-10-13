part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class RegisterIdentityEvent extends NotificationsEvent {
  final String userId;
  final String? memberCode;

  const RegisterIdentityEvent({required this.userId, this.memberCode});

  @override
  List<Object?> get props => [userId, memberCode];
}

class ClearIdentityEvent extends NotificationsEvent {
  const ClearIdentityEvent();
}
class RequestPermissionEvent extends NotificationsEvent {
  const RequestPermissionEvent();
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
