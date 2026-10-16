import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  final String _appId;
  final StreamController<IncomingNotification> _notifications =
      StreamController<IncomingNotification>.broadcast();
  final StreamController<NotificationPermission> _permission =
      StreamController<NotificationPermission>.broadcast();
  final StreamController<bool> _subscription =
      StreamController<bool>.broadcast();

  bool _initialized = false;
  Future<void>? _initFuture;

  NotificationService(this._appId);

  bool get isConfigured => _appId.trim().isNotEmpty;

  Stream<IncomingNotification> get onNotification => _notifications.stream;
  Stream<NotificationPermission> get onPermissionChange => _permission.stream;
  Stream<bool> get onSubscriptionChange => _subscription.stream;
  bool get isPushOptedIn =>
      _initialized && (OneSignal.User.pushSubscription.optedIn ?? false);

  Future<void> initialize() {
    if (kIsWeb || !isConfigured) return Future.value();
    return _initFuture ??= _init();
  }

  Future<void> _init() async {
    try {
      if (kDebugMode) OneSignal.Debug.setLogLevel(OSLogLevel.warn);
      await OneSignal.initialize(_appId.trim());

      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        _emit(event.notification, openedByUser: false);
      });
      OneSignal.Notifications.addClickListener((event) {
        _emit(event.notification, openedByUser: true);
      });
      OneSignal.Notifications.addPermissionObserver((_) async {
        if (!_permission.isClosed) _permission.add(await readPermission());
      });
      OneSignal.User.pushSubscription.addObserver((state) {
        if (!_subscription.isClosed) _subscription.add(state.current.optedIn);
      });

      _initialized = true;
    } catch (_) {
      _initFuture = null;
      rethrow;
    }
  }

  Future<NotificationPermission> readPermission() async {
    if (!isConfigured || kIsWeb) return NotificationPermission.unknown;
    await initialize();
    if (OneSignal.Notifications.permission) {
      return NotificationPermission.granted;
    }
    final canPrompt = await OneSignal.Notifications.canRequest();
    return canPrompt
        ? NotificationPermission.unknown
        : NotificationPermission.denied;
  }

  Future<void> login({
    required String userId,
    required Map<String, String> tags,
  }) async {
    if (!isConfigured || kIsWeb) return;
    await initialize();

    await OneSignal.login(userId);
    if (tags.isNotEmpty) {
      await OneSignal.User.addTags(tags);
    }
  }

  Future<void> logout({Iterable<String> tagKeys = const []}) async {
    if (!_initialized || kIsWeb) return;
    try {
      if (tagKeys.isNotEmpty) {
        await OneSignal.User.removeTags(tagKeys.toList());
      }
      await OneSignal.logout();
    } catch (e) {
      if (kDebugMode) debugPrint('[OneSignal] logout failed: $e');
    }
  }

  Future<bool> requestPermission({bool fallbackToSettings = true}) async {
    if (!isConfigured || kIsWeb) return false;
    await initialize();

    final granted = await OneSignal.Notifications.requestPermission(
      fallbackToSettings,
    );
    final effective = granted || OneSignal.Notifications.permission;

    if (!_permission.isClosed) _permission.add(await readPermission());
    return effective;
  }

  Future<void> setPushEnabled(bool enabled) async {
    if (!isConfigured || kIsWeb) return;
    await initialize();
    if (enabled) {
      await OneSignal.User.pushSubscription.optIn();
    } else {
      await OneSignal.User.pushSubscription.optOut();
    }
  }

  Future<void> dispose() async {
    await _notifications.close();
    await _permission.close();
    await _subscription.close();
  }

  void _emit(OSNotification n, {required bool openedByUser}) {
    if (_notifications.isClosed) return;

    final title = n.title?.trim();
    final body = n.body?.trim();

    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    final data = Map<String, dynamic>.from(n.additionalData ?? const {});
    final id = (data['notification_id'] as String?)?.trim();

    _notifications.add(
      IncomingNotification(
        id: id?.isNotEmpty == true
            ? id!
            : '${DateTime.now().microsecondsSinceEpoch}',
        title: title ?? '',
        body: body ?? '',
        data: data,
        openedByUser: openedByUser,
      ),
    );
  }
}

class IncomingNotification {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool openedByUser;

  const IncomingNotification({
    required this.id,
    required this.title,
    required this.body,
    this.data = const {},
    this.openedByUser = false,
  });
}

enum NotificationPermission { unknown, granted, denied }
