import 'package:equatable/equatable.dart';

class PackagePriceRule extends Equatable {
  final int? minAge;
  final int? maxAge;
  final String priceKes;

  const PackagePriceRule({
    required this.minAge,
    required this.maxAge,
    required this.priceKes,
  });

  @override
  List<Object?> get props => [minAge, maxAge, priceKes];
}

class PricingPackage extends Equatable {
  final String slug;
  final String label;
  final String description;
  final bool unlocksVitalsLogging;
  final List<PackagePriceRule> priceRules;
  final List<String> categories;

  const PricingPackage({
    required this.slug,
    required this.label,
    required this.description,
    required this.unlocksVitalsLogging,
    required this.priceRules,
    required this.categories,
  });

  @override
  List<Object?> get props => [
    slug,
    label,
    description,
    unlocksVitalsLogging,
    priceRules,
    categories,
  ];
}
