
part of 'notifications_bloc.dart';

enum NotificationsStatus {
  idle,
  syncing,
  connected,
  permissionDenied,
  notConfigured,
  error,
}

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final NotificationPermission permission;
  final AppNotification? pending;
  final int unreadCount;

  const NotificationsState({
    this.status = NotificationsStatus.idle,
    this.permission = NotificationPermission.unknown,
    this.pending,
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    NotificationPermission? permission,
    AppNotification? pending,
    int? unreadCount,
    bool clearPending = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      permission: permission ?? this.permission,
      pending: clearPending ? null : (pending ?? this.pending),
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [status, permission, pending, unreadCount];
}
