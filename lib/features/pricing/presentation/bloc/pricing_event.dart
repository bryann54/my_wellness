part of 'pricing_bloc.dart';

abstract class PricingEvent extends Equatable {
  const PricingEvent();

  @override
  List<Object?> get props => [];
}

class LoadPricingPackagesEvent extends PricingEvent {
  const LoadPricingPackagesEvent();
}
