part of 'pricing_bloc.dart';

abstract class PricingEvent extends Equatable {
  const PricingEvent();

  @override
  List<Object?> get props => [];
}

class LoadPricingPackagesEvent extends PricingEvent {
  final bool refresh;
  const LoadPricingPackagesEvent({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadPricingPackagesForCategoryEvent extends PricingEvent {
  final String category;
  final bool refresh;
  const LoadPricingPackagesForCategoryEvent({
    required this.category,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [category, refresh];
}

class QuotePricingSelectionEvent extends PricingEvent {
  final Map<String, dynamic> selection;
  const QuotePricingSelectionEvent(this.selection);

  @override
  List<Object?> get props => [selection];
}

class CheckoutPricingSelectionEvent extends PricingEvent {
  final Map<String, dynamic> selection;
  final String phone;
  final String? idempotencyKey;

  const CheckoutPricingSelectionEvent({
    required this.selection,
    required this.phone,
    this.idempotencyKey,
  });

  @override
  List<Object?> get props => [selection, idempotencyKey];
}

class StkPushEvent extends PricingEvent {
  final String phone;
  final int amount;
  final String serviceType;
  final String idempotencyKey;
  final String? sessionId;
  final String? bookingId;
  final String? invoiceId;
  final String? packageId;
  final int? age;

  final List<String> packageCategories;

  const StkPushEvent({
    required this.phone,
    required this.amount,
    required this.serviceType,
    required this.idempotencyKey,
    this.sessionId,
    this.bookingId,
    this.invoiceId,
    this.packageId,
    this.age,
    this.packageCategories = const [],
  });

  @override
  List<Object?> get props => [
    amount,
    serviceType,
    idempotencyKey,
    sessionId,
    bookingId,
    invoiceId,
    packageId,
    age,
    packageCategories,
  ];
}

class PollPaymentStatusEvent extends PricingEvent {
  final String paymentId;
  const PollPaymentStatusEvent({required this.paymentId});

  @override
  List<Object?> get props => [paymentId];
}

class PollModuleAccessEvent extends PricingEvent {
  final Set<String> categories;
  final bool waitVitals;
  const PollModuleAccessEvent({
    this.categories = const {},
    this.waitVitals = false,
  });

  @override
  List<Object?> get props => [categories, waitVitals];
}

class CancelPollingEvent extends PricingEvent {
  const CancelPollingEvent();
}
