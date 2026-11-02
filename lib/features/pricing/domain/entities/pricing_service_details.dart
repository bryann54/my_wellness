import 'package:equatable/equatable.dart';

class PricingBenefit extends Equatable {
  final String title;
  final String description;
  const PricingBenefit({required this.title, required this.description});

  @override
  List<Object?> get props => [title, description];
}

class PricingServiceDetails extends Equatable {
  final String? iconKey;
  final String? accentHex;
  final String? bgHex;
  final String? unit;
  final List<PricingBenefit> benefits;
  final List<String> report;
  final String? priceDisplay;

  const PricingServiceDetails({
    this.iconKey,
    this.accentHex,
    this.bgHex,
    this.unit,
    this.benefits = const [],
    this.report = const [],
    this.priceDisplay,
  });

  @override
  List<Object?> get props => [
    iconKey,
    accentHex,
    bgHex,
    unit,
    benefits,
    report,
    priceDisplay,
  ];
}
