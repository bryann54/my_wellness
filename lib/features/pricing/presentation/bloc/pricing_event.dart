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

class QuotePricingSelectionEvent extends PricingEvent {
  final Map<String, dynamic> selection;
  const QuotePricingSelectionEvent(this.selection);

  @override
  List<Object?> get props => [selection];
}

class CheckoutPricingSelectionEvent extends PricingEvent {
  final Map<String, dynamic> selection;
  final String phone;
  const CheckoutPricingSelectionEvent({
    required this.selection,
    required this.phone,
  });

  @override
  // Never include the phone number in the event representation/log string.
  List<Object?> get props => [selection];
}
