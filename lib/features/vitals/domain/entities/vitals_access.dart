import 'package:equatable/equatable.dart';

class VitalsAccess extends Equatable {
  final bool hasAccess;
  final bool demoRestricted;
  final String? navigatorAlertedAt;

  const VitalsAccess({
    required this.hasAccess,
    required this.demoRestricted,
    this.navigatorAlertedAt,
  });

  bool get navigatorAlerted =>
      navigatorAlertedAt != null && navigatorAlertedAt!.isNotEmpty;

  @override
  List<Object?> get props => [hasAccess, demoRestricted, navigatorAlertedAt];
}
