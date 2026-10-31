import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/notifications/data/notification_service.dart';
import 'package:my_wellness/features/notifications/domain/entities/app_notification.dart';
import 'package:my_wellness/features/notifications/domain/entities/notification_preference.dart';
import 'package:my_wellness/features/notifications/domain/usecases/notification_preferences_usecases.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

@injectable
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationService _service;
  final NotificationPreferencesUseCases _preferencesUseCases;

  StreamSubscription<IncomingNotification>? _incomingSub;
  StreamSubscription<NotificationPermission>? _permissionSub;
  StreamSubscription<bool>? _subscriptionSub;

  NotificationsBloc(this._service, this._preferencesUseCases)
    : super(const NotificationsState()) {
    on<RegisterIdentityEvent>(_onRegister);
    on<ClearIdentityEvent>(_onClear);
    on<RefreshPermissionEvent>(_onRefresh);
    on<SetPushEnabledEvent>(_onSetPushEnabled);
    on<PermissionChangedEvent>(
      (e, emit) => emit(state.copyWith(permission: e.permission)),
    );
    on<SubscriptionChangedEvent>(
      (e, emit) => emit(state.copyWith(pushOptedIn: e.optedIn)),
    );
    on<IncomingNotificationEvent>(_onIncoming);
    on<NotificationTappedEvent>(
      (e, emit) => emit(state.copyWith(clearPending: true)),
    );
    on<MarkAllReadEvent>((e, emit) {
      if (state.unreadCount != 0) emit(state.copyWith(unreadCount: 0));
    });
    on<LoadNotificationPreferencesEvent>(_onLoadPreferences);
    on<SetNotificationPreferenceChannelEvent>(_onSetPreferenceChannel);
    on<SaveNotificationPreferencesEvent>(_onSavePreferences);

    _wireStreams();
  }

  void _wireStreams() {
    _incomingSub = _service.onNotification.listen(
      (n) => add(IncomingNotificationEvent(n)),
    );
    _permissionSub = _service.onPermissionChange.listen(
      (p) => add(PermissionChangedEvent(p)),
    );
    _subscriptionSub = _service.onSubscriptionChange.listen(
      (v) => add(SubscriptionChangedEvent(v)),
    );
  }

  Future<void> _onRegister(
    RegisterIdentityEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (!_service.isConfigured) {
      emit(state.copyWith(status: NotificationsStatus.notConfigured));
      return;
    }

    emit(state.copyWith(status: NotificationsStatus.syncing));

    try {
      await _service.login(userId: event.userId);

      emit(
        state.copyWith(
          status: NotificationsStatus.connected,
          permission: await _service.readPermission(),
          pushOptedIn: _service.isPushOptedIn,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: NotificationsStatus.error));
    }
  }

  Future<void> _onClear(
    ClearIdentityEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _service.logout();
    emit(const NotificationsState());
  }

  Future<void> _onRefresh(
    RefreshPermissionEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (!_service.isConfigured) return;
    emit(
      state.copyWith(
        permission: await _service.readPermission(),
        pushOptedIn: _service.isPushOptedIn,
      ),
    );
  }

  Future<void> _onLoadPreferences(
    LoadNotificationPreferencesEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.preferencesLoading || state.preferences.isNotEmpty) return;
    emit(state.copyWith(preferencesLoading: true, clearPreferencesError: true));
    final result = await _preferencesUseCases.load();
    result.fold(
      (failure) => emit(
        state.copyWith(
          preferencesLoading: false,
          preferencesError: mapFailure(failure),
        ),
      ),
      (preferences) => emit(
        state.copyWith(
          preferencesLoading: false,
          preferences: preferences,
          savedPreferences: preferences,
        ),
      ),
    );
  }

  void _onSetPreferenceChannel(
    SetNotificationPreferenceChannelEvent event,
    Emitter<NotificationsState> emit,
  ) {
    final updated = state.preferences
        .map((preference) {
          if (preference.category != event.category) return preference;
          final next = switch (event.channel) {
            NotificationChannel.push => preference.copyWith(
              push: event.enabled,
            ),
            NotificationChannel.email => preference.copyWith(
              email: event.enabled,
            ),
            NotificationChannel.sms => preference.copyWith(sms: event.enabled),
          };
          if (next.required && !next.hasEnabledChannel) return preference;
          return next;
        })
        .toList(growable: false);
    emit(
      state.copyWith(
        preferences: updated,
        preferencesSaved: false,
        clearPreferencesError: true,
      ),
    );
  }

  Future<void> _onSavePreferences(
    SaveNotificationPreferencesEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.savingPreferences) return;
    if (state.preferences.any(
      (item) => item.required && !item.hasEnabledChannel,
    )) {
      emit(
        state.copyWith(
          preferencesError:
              'At least one channel must stay on for medication reminders.',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        savingPreferences: true,
        preferencesSaved: false,
        clearPreferencesError: true,
      ),
    );
    final result = await _preferencesUseCases.save(state.preferences);
    result.fold(
      (failure) => emit(
        state.copyWith(
          savingPreferences: false,
          preferencesError: mapFailure(failure),
        ),
      ),
      (preferences) => emit(
        state.copyWith(
          savingPreferences: false,
          preferences: preferences,
          savedPreferences: preferences,
          preferencesSaved: true,
        ),
      ),
    );
  }

  Future<void> _onSetPushEnabled(
    SetPushEnabledEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.isUpdating || !_service.isConfigured) return;
    emit(state.copyWith(isUpdating: true));

    try {
      if (event.enabled) {
        var permission = await _service.readPermission();

        if (permission != NotificationPermission.granted) {
          final granted = await _service.requestPermission(
            fallbackToSettings: true,
          );
          if (!granted) {
            emit(
              state.copyWith(
                isUpdating: false,
                permission: await _service.readPermission(),
              ),
            );
            return;
          }
          permission = NotificationPermission.granted;
        }

        await _service.setPushEnabled(true);
        emit(
          state.copyWith(
            isUpdating: false,
            permission: permission,
            pushOptedIn: true,
          ),
        );
      } else {
        await _service.setPushEnabled(false);
        emit(state.copyWith(isUpdating: false, pushOptedIn: false));
      }
    } catch (_) {
      emit(
        state.copyWith(
          isUpdating: false,
          permission: await _service.readPermission(),
          pushOptedIn: _service.isPushOptedIn,
        ),
      );
    }
  }

  void _onIncoming(
    IncomingNotificationEvent event,
    Emitter<NotificationsState> emit,
  ) {
    final incoming = event.notification;
    emit(
      state.copyWith(
        pending: AppNotification(
          id: incoming.id,
          title: incoming.title,
          body: incoming.body,
          route: parseNotificationRoute(incoming.data),
          receivedAt: DateTime.now(),
          openedByUser: incoming.openedByUser,
        ),
        unreadCount: incoming.openedByUser
            ? state.unreadCount
            : state.unreadCount + 1,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _incomingSub?.cancel();
    await _permissionSub?.cancel();
    await _subscriptionSub?.cancel();
    return super.close();
  }
}
