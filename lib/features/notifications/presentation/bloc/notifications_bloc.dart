import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/features/notifications/data/notification_service.dart';
import 'package:my_wellness/features/notifications/domain/entities/app_notification.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

@injectable
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  static const _tagKeys = ['user_id', 'member_code', 'audience'];

  final NotificationService _service;

  StreamSubscription<IncomingNotification>? _incomingSub;
  StreamSubscription<NotificationPermission>? _permissionSub;

  NotificationsBloc(this._service) : super(const NotificationsState()) {
    on<RegisterIdentityEvent>(_onRegister);
    on<ClearIdentityEvent>(_onClear);
    on<RequestPermissionEvent>(_onRequestPermission);
    on<IncomingNotificationEvent>(_onIncoming);
    on<NotificationTappedEvent>(_onTapped);

    _wireStreams();
  }

  void _wireStreams() {
    _incomingSub = _service.onNotification.listen((n) {
      add(IncomingNotificationEvent(n));
    });
    _permissionSub = _service.onPermissionChange.listen((p) {
      if (!isClosed) emit(state.copyWith(permission: p));
    });
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
      final tags = <String, String>{
        'user_id': event.userId,
        'audience': 'patient',
        if (event.memberCode?.isNotEmpty ?? false)
          'member_code': event.memberCode!,
      };

      await _service.login(userId: event.userId, tags: tags);
      await _service.requestPermission(fallbackToSettings: false);

      emit(
        state.copyWith(
          status: NotificationsStatus.connected,
          permission: _service.permission,
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
    await _service.logout(tagKeys: _tagKeys);
    emit(const NotificationsState());
  }

  Future<void> _onRequestPermission(
    RequestPermissionEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final granted = await _service.requestPermission(fallbackToSettings: true);
    emit(
      state.copyWith(
        permission: granted
            ? NotificationPermission.granted
            : NotificationPermission.denied,
        status: granted
            ? NotificationsStatus.connected
            : NotificationsStatus.permissionDenied,
      ),
    );
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
      ),
    );
  }

  void _onTapped(
    NotificationTappedEvent event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(clearPending: true));
  }

  @override
  Future<void> close() async {
    await _incomingSub?.cancel();
    await _permissionSub?.cancel();
    return super.close();
  }
}
