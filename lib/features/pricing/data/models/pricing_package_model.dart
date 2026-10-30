import 'package:my_wellness/features/pricing/domain/entities/pricing_package.dart';

class PackagePriceRuleModel {
  final int? minAge;
  final int? maxAge;
  final String priceKes;

  const PackagePriceRuleModel({
    required this.minAge,
    required this.maxAge,
    required this.priceKes,
  });

  factory PackagePriceRuleModel.fromJson(Map<String, dynamic> json) {
    return PackagePriceRuleModel(
      minAge: _parseInt(json['min_age']),
      maxAge: _parseInt(json['max_age']),
      priceKes: json['price_kes']?.toString() ?? '',
    );
  }

  PackagePriceRule toEntity() =>
      PackagePriceRule(minAge: minAge, maxAge: maxAge, priceKes: priceKes);
}

class PricingPackageModel {
  final String slug;
  final String label;
  final String description;
  final bool unlocksVitalsLogging;
  final List<PackagePriceRuleModel> priceRules;
  final List<String> categories;

  const PricingPackageModel({
    required this.slug,
    required this.label,
    required this.description,
    required this.unlocksVitalsLogging,
    required this.priceRules,
    required this.categories,
  });

  factory PricingPackageModel.fromJson(Map<String, dynamic> json) {
    final rawRules = json['price_rules'];
    final rawCategories = json['categories'];

    return PricingPackageModel(
      slug: json['slug']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      unlocksVitalsLogging: json['unlocks_vitals_logging'] == true,
      priceRules: rawRules is List
          ? rawRules
                .whereType<Map<String, dynamic>>()
                .map(PackagePriceRuleModel.fromJson)
                .toList(growable: false)
          : const [],
      categories: rawCategories is List
          ? rawCategories
                .map((value) => value.toString())
                .toList(growable: false)
          : const [],
    );
  }

  PricingPackage toEntity() => PricingPackage(
    slug: slug,
    label: label,
    description: description,
    unlocksVitalsLogging: unlocksVitalsLogging,
    priceRules: priceRules
        .map((rule) => rule.toEntity())
        .toList(growable: false),
    categories: categories,
  );
}

int? _parseInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
