import 'package:equatable/equatable.dart';

class RCEntitlement extends Equatable {
  final String identifier;
  final bool isActive;
  final DateTime? expirationDate;
  final String? productIdentifier;
  final String? store;

  const RCEntitlement({
    required this.identifier,
    required this.isActive,
    this.expirationDate,
    this.productIdentifier,
    this.store,
  });

  @override
  List<Object?> get props => [identifier, isActive, expirationDate];
}
