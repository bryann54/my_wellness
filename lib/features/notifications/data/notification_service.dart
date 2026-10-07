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
///   - payload parsing / routing
///   - snackbar or navigation presentation
class NotificationService {
  static const externalIdPrefix = 'user-';

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

  /// Safe to call multiple times. Returns immediately on web or when
  /// [isConfigured] is false.
  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    if (!isConfigured) return;

    if (kDebugMode) {
      OneSignal.Debug.setLogLevel(OSLogLevel.warn);
    }
    await OneSignal.initialize(_appId.trim());

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      _emit(event.notification);
    });
    OneSignal.Notifications.addClickListener((event) {
      _emit(event.notification);
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
  /// Caller is responsible for resolving [userId] and [tags] from an
  /// authenticated source. This method does not talk to your API.
  Future<void> login({
    required String userId,
    required Map<String, String> tags,
  }) async {
    if (!isConfigured || kIsWeb) return;
    await initialize();

    await OneSignal.login('$externalIdPrefix$userId');
    if (tags.isNotEmpty) {
      await OneSignal.User.addTags(tags);
    }
  }

  /// Removes this device's targeting from OneSignal.
  ///
  /// Best-effort. Failures are swallowed so logout never blocks.
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

  /// Requests OS notification permission.
  ///
  /// [fallbackToSettings] should be false during automatic post-login setup
  /// (do not surprise the user) and true when the user explicitly taps a
  /// "Enable notifications" button in the app.
  Future<bool> requestPermission({bool fallbackToSettings = true}) async {
    if (!isConfigured || kIsWeb) return false;
    await initialize();

    final granted = await OneSignal.Notifications.requestPermission(
      fallbackToSettings,
    );
    final effective = granted || OneSignal.Notifications.permission;

    // Permission and subscription opt-in are separate OneSignal states.
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

  void _emit(OSNotification n) {
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

  const IncomingNotification({
    required this.id,
    required this.title,
    required this.body,
    this.data = const {},
  });
}

enum NotificationPermission { unknown, granted, denied }
