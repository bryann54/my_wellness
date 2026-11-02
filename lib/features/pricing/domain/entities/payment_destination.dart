import 'package:equatable/equatable.dart';

enum PricingDestination {
  cancerHub,
  metabolicList,
  mentalList,
  womensHealthHub,
  sexualUrinaryPage,
  monitoring,
  checkup,
  dashboard,
  backToAssessmentSession,
}

class PaymentAccessRequirement extends Equatable {
  final Set<String> categories;
  final bool waitVitals;
  const PaymentAccessRequirement({
    this.categories = const {},
    this.waitVitals = false,
  });

  bool get isEmpty => categories.isEmpty && !waitVitals;

  @override
  List<Object?> get props => [categories, waitVitals];
}

class PaymentDestinationResult extends Equatable {
  final PricingDestination destination;
  final PaymentAccessRequirement requirement;

  final String? returnToSessionId;

  const PaymentDestinationResult({
    required this.destination,
    required this.requirement,
    this.returnToSessionId,
  });

  @override
  List<Object?> get props => [destination, requirement, returnToSessionId];
}

PaymentDestinationResult resolvePaymentDestination({
  required Set<String> serviceIds,
  String? bundleId,
  String? returnToSessionId,
}) {
  final hasCancer = serviceIds.contains('cancer');
  final isAllInOne = bundleId == 'all_in_one';
  final isMonitoring = serviceIds.contains('monitor');
  final isCheckup = serviceIds.contains('checkup');
  final isOpinion = serviceIds.contains('opinion');

  if (hasCancer || isAllInOne) {
    return PaymentDestinationResult(
      destination: returnToSessionId != null
          ? PricingDestination.backToAssessmentSession
          : PricingDestination.cancerHub,
      requirement: const PaymentAccessRequirement(categories: {'Cancer'}),
      returnToSessionId: returnToSessionId,
    );
  }

  if (isMonitoring) {
    return PaymentDestinationResult(
      destination: PricingDestination.monitoring,
      requirement: const PaymentAccessRequirement(waitVitals: true),
      returnToSessionId: returnToSessionId,
    );
  }

  if (isCheckup) {
    return const PaymentDestinationResult(
      destination: PricingDestination.checkup,
      requirement: PaymentAccessRequirement(),
    );
  }

  if (isOpinion) {
    return const PaymentDestinationResult(
      destination: PricingDestination.dashboard,
      requirement: PaymentAccessRequirement(),
    );
  }

  final categories = <String>{};
  if (serviceIds.contains('metabolic')) categories.add('Metabolic');
  if (serviceIds.contains('mental')) categories.add('Mental health');
  if (serviceIds.contains('women')) categories.add('Reproductive health');
  if (serviceIds.contains('sexual')) categories.add('Sexual & urinary');

  if (categories.length == 1 && categories.first == 'Metabolic') {
    return PaymentDestinationResult(
      destination: PricingDestination.metabolicList,
      requirement: PaymentAccessRequirement(categories: categories),
      returnToSessionId: returnToSessionId,
    );
  }
  if (categories.length == 1 && categories.first == 'Mental health') {
    return PaymentDestinationResult(
      destination: PricingDestination.mentalList,
      requirement: PaymentAccessRequirement(categories: categories),
      returnToSessionId: returnToSessionId,
    );
  }
  if (categories.length == 1 && categories.first == 'Reproductive health') {
    return PaymentDestinationResult(
      destination: PricingDestination.womensHealthHub,
      requirement: PaymentAccessRequirement(categories: categories),
      returnToSessionId: returnToSessionId,
    );
  }
  if (categories.length == 1 && categories.first == 'Sexual & urinary') {
    return PaymentDestinationResult(
      destination: PricingDestination.sexualUrinaryPage,
      requirement: PaymentAccessRequirement(categories: categories),
      returnToSessionId: returnToSessionId,
    );
  }

  return PaymentDestinationResult(
    destination: PricingDestination.dashboard,
    requirement: PaymentAccessRequirement(categories: categories),
    returnToSessionId: returnToSessionId,
  );
}

PaymentDestinationResult resolvePackageDestination({
  required List<String> categories,
  String? returnToSessionId,
}) {
  final set = categories.toSet();
  if (set.contains('Cancer')) {
    return PaymentDestinationResult(
      destination: returnToSessionId != null
          ? PricingDestination.backToAssessmentSession
          : PricingDestination.cancerHub,
      requirement: PaymentAccessRequirement(categories: const {'Cancer'}),
      returnToSessionId: returnToSessionId,
    );
  }
  if (set.contains('Monitoring')) {
    return const PaymentDestinationResult(
      destination: PricingDestination.monitoring,
      requirement: PaymentAccessRequirement(waitVitals: true),
    );
  }
  return PaymentDestinationResult(
    destination: PricingDestination.dashboard,
    requirement: PaymentAccessRequirement(categories: set),
    returnToSessionId: returnToSessionId,
  );
}
