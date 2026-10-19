import 'package:equatable/equatable.dart';

enum DeviceSecurity { secured, unsecured }

enum UnlockOutcome { success, cancelled, lockedOut, unavailable, failed }

class AppLockStatus extends Equatable {
  final bool enabled;
  final bool prompted;
  final DeviceSecurity security;

  const AppLockStatus({
    required this.enabled,
    required this.prompted,
    required this.security,
  });

  bool get shouldLock => enabled && security == DeviceSecurity.secured;

  @override
  List<Object?> get props => [enabled, prompted, security];
}
