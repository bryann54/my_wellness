import 'package:equatable/equatable.dart';
import 'pricing_service_details.dart';

class PricingService extends Equatable {
  final String serviceId;
  final String name;
  final String shortDescription;
  final String priceDisplay;
  final int? basePriceKes;
  final bool isProposed;

  final PricingServiceDetails? details;

  const PricingService({
    required this.serviceId,
    required this.name,
    required this.shortDescription,
    required this.priceDisplay,
    this.basePriceKes,
    this.isProposed = false,
    this.details,
  });

  @override
  List<Object?> get props => [
    serviceId,
    name,
    shortDescription,
    priceDisplay,
    basePriceKes,
    isProposed,
    details,
  ];
}

class PricingBundle extends Equatable {
  final String bundleId;
  final String name;
  final String description;
  final List<String> serviceIds;
  final int priceKes;

  final PricingServiceDetails? details;

  const PricingBundle({
    required this.bundleId,
    required this.name,
    required this.description,
    required this.serviceIds,
    required this.priceKes,
    this.details,
  });

  @override
  List<Object?> get props => [
    bundleId,
    name,
    description,
    serviceIds,
    priceKes,
    details,
  ];
}

class PricingCatalog extends Equatable {
  final List<PricingService> services;
  final List<PricingBundle> combos;
  final PricingBundle? allInOne;

  const PricingCatalog({
    this.services = const [],
    this.combos = const [],
    this.allInOne,
  });

  static const hiddenServiceIds = {'workplace'};

  List<PricingService> get visibleServices => services
      .where((s) => !hiddenServiceIds.contains(s.serviceId))
      .toList(growable: false);

  List<PricingBundle> get visibleCombos => combos
      .where((b) => b.serviceIds.every((id) => !hiddenServiceIds.contains(id)))
      .toList(growable: false);

  @override
  List<Object?> get props => [services, combos, allInOne];
}

class PricingQuoteLine extends Equatable {
  final String serviceId;
  final int priceKes;
  final bool isFree;
  final bool isDiscounted;

  const PricingQuoteLine({
    required this.serviceId,
    required this.priceKes,
    this.isFree = false,
    this.isDiscounted = false,
  });

  @override
  List<Object?> get props => [serviceId, priceKes, isFree, isDiscounted];
}

class PricingQuote extends Equatable {
  final List<PricingQuoteLine> lines;
  final int discountKes;
  final int totalKes;
  final String? cheaperComboId;
  final int? cheaperComboPriceKes;
  final String? bundleId;

  const PricingQuote({
    this.lines = const [],
    this.discountKes = 0,
    required this.totalKes,
    this.cheaperComboId,
    this.cheaperComboPriceKes,
    this.bundleId,
  });

  @override
  List<Object?> get props => [
    lines,
    discountKes,
    totalKes,
    cheaperComboId,
    cheaperComboPriceKes,
    bundleId,
  ];
}

class PricingPayment extends Equatable {
  final String id;
  final String status;
  final String phoneNumber;
  final int amountKes;

  final String? checkoutRequestId;
  final String? serviceType;
  final String? packageId;
  final String? mpesaReceipt;
  final String? createdAt;

  const PricingPayment({
    required this.id,
    required this.status,
    required this.phoneNumber,
    required this.amountKes,
    this.checkoutRequestId,
    this.serviceType,
    this.packageId,
    this.mpesaReceipt,
    this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';

  @override
  List<Object?> get props => [
    id,
    status,
    phoneNumber,
    amountKes,
    checkoutRequestId,
    serviceType,
    packageId,
    mpesaReceipt,
    createdAt,
  ];
}
