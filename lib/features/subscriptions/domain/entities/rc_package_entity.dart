import 'package:equatable/equatable.dart';

enum RCPackageType { monthly, annual, weekly, lifetime, unknown }

class RCPackage extends Equatable {
  final String identifier;
  final RCPackageType packageType;
  final String productIdentifier;
  final String localizedPriceString;
  final String localizedTitle;
  final String localizedDescription;

  const RCPackage({
    required this.identifier,
    required this.packageType,
    required this.productIdentifier,
    required this.localizedPriceString,
    required this.localizedTitle,
    required this.localizedDescription,
  });

  @override
  List<Object?> get props => [identifier, productIdentifier];
}
