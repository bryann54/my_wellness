part of 'notifications_bloc.dart';

enum NotificationsStatus { idle, syncing, connected, notConfigured, error }

class NotificationsState extends Equatable {
  final NotificationsStatus status;

  final NotificationPermission permission;

  final bool pushOptedIn;

  final bool isUpdating;

  final AppNotification? pending;
  final int unreadCount;

  const NotificationsState({
    this.status = NotificationsStatus.idle,
    this.permission = NotificationPermission.unknown,
    this.pushOptedIn = false,
    this.isUpdating = false,
    this.pending,
    this.unreadCount = 0,
  });

  bool get pushEnabled =>
      permission == NotificationPermission.granted && pushOptedIn;

  NotificationsState copyWith({
    NotificationsStatus? status,
    NotificationPermission? permission,
    bool? pushOptedIn,
    bool? isUpdating,
    AppNotification? pending,
    int? unreadCount,
    bool clearPending = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      permission: permission ?? this.permission,
      pushOptedIn: pushOptedIn ?? this.pushOptedIn,
      isUpdating: isUpdating ?? this.isUpdating,
      pending: clearPending ? null : (pending ?? this.pending),
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
    status,
    permission,
    pushOptedIn,
    isUpdating,
    pending,
    unreadCount,
  ];
}
