import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Thin wrapper around the OneSignal Flutter SDK.
///
/// Owns:
///   - SDK initialization (idempotent)
///   - external-ID login / logout
///   - tag add / remove
///   - permission requests
///   - two broadcast streams: incoming notifications, permission changes
///
/// Does NOT own:
///   - identity resolution (that's the bloc's job)
///   - payload parsing / routing (that's the host's job)
///   - snackbar or navigation presentation
class NotificationService {
  final String _appId;
  final StreamController<IncomingNotification> _notifications =
      StreamController<IncomingNotification>.broadcast();
  final StreamController<NotificationPermission> _permission =
      StreamController<NotificationPermission>.broadcast();

  bool _initialized = false;

  NotificationService(this._appId);

  bool get isConfigured => _appId.trim().isNotEmpty;

  Stream<IncomingNotification> get onNotification => _notifications.stream;
  Stream<NotificationPermission> get onPermissionChange => _permission.stream;

  NotificationPermission get permission =>
      _mapPermission(OneSignal.Notifications.permission);

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    if (!isConfigured) return;

    if (kDebugMode) {
      OneSignal.Debug.setLogLevel(OSLogLevel.warn);
    }
    await OneSignal.initialize(_appId.trim());

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      _emit(event.notification, openedByUser: false);
    });

    OneSignal.Notifications.addClickListener((event) {
      _emit(event.notification, openedByUser: true);
    });

    OneSignal.Notifications.addPermissionObserver((granted) {
      _permission.add(
        granted
            ? NotificationPermission.granted
            : NotificationPermission.denied,
      );
    });

    _initialized = true;
  }

  /// Associates this device with a user in OneSignal.
  ///
  /// [userId] is expected to be the raw UUID from the API. This method
  /// does not add a prefix — the backend targets the same value verbatim.
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

    if (effective) {
      await OneSignal.User.pushSubscription.optIn();
    }

    _permission.add(
      effective
          ? NotificationPermission.granted
          : NotificationPermission.denied,
    );
    return effective;
  }

  Future<void> dispose() async {
    await _notifications.close();
    await _permission.close();
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

  static NotificationPermission _mapPermission(bool granted) =>
      granted ? NotificationPermission.granted : NotificationPermission.denied;
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
