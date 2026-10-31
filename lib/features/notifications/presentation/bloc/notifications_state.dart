part of 'notifications_bloc.dart';

enum NotificationsStatus { idle, syncing, connected, notConfigured, error }

class NotificationsState extends Equatable {
  final NotificationsStatus status;

  final NotificationPermission permission;

  final bool pushOptedIn;

  final bool isUpdating;

  final AppNotification? pending;
  final int unreadCount;
  final List<NotificationPreference> preferences;
  final List<NotificationPreference> savedPreferences;
  final bool preferencesLoading;
  final bool savingPreferences;
  final bool preferencesSaved;
  final String? preferencesError;

  const NotificationsState({
    this.status = NotificationsStatus.idle,
    this.permission = NotificationPermission.unknown,
    this.pushOptedIn = false,
    this.isUpdating = false,
    this.pending,
    this.unreadCount = 0,
    this.preferences = const [],
    this.savedPreferences = const [],
    this.preferencesLoading = false,
    this.savingPreferences = false,
    this.preferencesSaved = false,
    this.preferencesError,
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
    List<NotificationPreference>? preferences,
    List<NotificationPreference>? savedPreferences,
    bool? preferencesLoading,
    bool? savingPreferences,
    bool? preferencesSaved,
    String? preferencesError,
    bool clearPreferencesError = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      permission: permission ?? this.permission,
      pushOptedIn: pushOptedIn ?? this.pushOptedIn,
      isUpdating: isUpdating ?? this.isUpdating,
      pending: clearPending ? null : (pending ?? this.pending),
      unreadCount: unreadCount ?? this.unreadCount,
      preferences: preferences ?? this.preferences,
      savedPreferences: savedPreferences ?? this.savedPreferences,
      preferencesLoading: preferencesLoading ?? this.preferencesLoading,
      savingPreferences: savingPreferences ?? this.savingPreferences,
      preferencesSaved: preferencesSaved ?? this.preferencesSaved,
      preferencesError: clearPreferencesError
          ? null
          : preferencesError ?? this.preferencesError,
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
    preferences,
    savedPreferences,
    preferencesLoading,
    savingPreferences,
    preferencesSaved,
    preferencesError,
  ];
}
