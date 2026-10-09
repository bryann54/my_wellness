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

  /// Latest notification surfaced to the host. Consumed once and cleared
  /// via [NotificationTappedEvent].
  final AppNotification? pending;

  const NotificationsState({
    this.status = NotificationsStatus.idle,
    this.permission = NotificationPermission.unknown,
    this.pending,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    NotificationPermission? permission,
    AppNotification? pending,
    bool clearPending = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      permission: permission ?? this.permission,
      pending: clearPending ? null : (pending ?? this.pending),
    );
  }

  @override
  List<Object?> get props => [status, permission, pending];
}
