import 'package:my_wellness/features/pricing/domain/entities/pricing_catalog.dart';

class PricingCatalogModel {
  final List<PricingService> services;
  final List<PricingBundle> combos;
  final PricingBundle? allInOne;

  const PricingCatalogModel({
    required this.services,
    required this.combos,
    required this.allInOne,
  });

  factory PricingCatalogModel.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'];
    final rawCombos = json['combos'];
    final rawAll = json['all_in_one'];
    return PricingCatalogModel(
      services: rawServices is List
          ? rawServices
                .whereType<Map<String, dynamic>>()
                .map(_serviceFromJson)
                .toList(growable: false)
          : const [],
      combos: rawCombos is List
          ? rawCombos
                .whereType<Map<String, dynamic>>()
                .map(_bundleFromJson)
                .toList(growable: false)
          : const [],
      allInOne: rawAll is Map<String, dynamic> ? _bundleFromJson(rawAll) : null,
    );
  }

  PricingCatalog toEntity() =>
      PricingCatalog(services: services, combos: combos, allInOne: allInOne);
}

PricingService _serviceFromJson(Map<String, dynamic> json) => PricingService(
  serviceId: json['service_id']?.toString() ?? '',
  name: json['name']?.toString() ?? '',
  shortDescription: json['short_description']?.toString() ?? '',
  priceDisplay: json['price_display']?.toString() ?? '',
  basePriceKes: _integer(json['base_price_kes']),
  isProposed: json['is_proposed'] == true,
);

PricingBundle _bundleFromJson(Map<String, dynamic> json) => PricingBundle(
  bundleId: (json['bundle_id'] ?? json['combo_id'])?.toString() ?? '',
  name: json['name']?.toString() ?? '',
  description: json['description']?.toString() ?? '',
  serviceIds:
      (json['service_ids'] as List<dynamic>?)
          ?.map((id) => id.toString())
          .toList(growable: false) ??
      const [],
  priceKes: _integer(json['price_kes']) ?? 0,
);

int? _integer(dynamic value) => value is num
    ? value.toInt()
    : num.tryParse(value?.toString() ?? '')?.toInt();

class PricingQuoteModel {
  final PricingQuote quote;

  const PricingQuoteModel(this.quote);

  factory PricingQuoteModel.fromJson(Map<String, dynamic> json) {
    final lines = json['lines'];
    final cheaper = json['cheaper_combo'];
    return PricingQuoteModel(
      PricingQuote(
        lines: lines is List
            ? lines
                  .whereType<Map<String, dynamic>>()
                  .map(
                    (line) => PricingQuoteLine(
                      serviceId: line['service_id']?.toString() ?? '',
                      priceKes: _integer(line['price_kes']) ?? 0,
                      isFree: line['is_free'] == true,
                      isDiscounted: line['is_discounted'] == true,
                    ),
                  )
                  .toList(growable: false)
            : const [],
        discountKes: _integer(json['discount_kes']) ?? 0,
        totalKes: _integer(json['total_kes']) ?? 0,
        cheaperComboId: cheaper is Map ? cheaper['combo_id']?.toString() : null,
        cheaperComboPriceKes: cheaper is Map
            ? _integer(cheaper['price_kes'])
            : null,
        bundleId: json['bundle_id']?.toString(),
      ),
    );
  }
}

PricingPayment paymentFromJson(Map<String, dynamic> json) => PricingPayment(
  id: json['id']?.toString() ?? '',
  status: json['status']?.toString() ?? 'pending',
  phoneNumber: json['phone_number']?.toString() ?? '',
  amountKes: _integer(json['amount']) ?? 0,
);
