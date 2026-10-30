part of 'pricing_bloc.dart';

enum PricingStatus { initial, loading, loaded, error }

class PricingState extends Equatable {
  final PricingStatus status;
  final List<PricingPackage> packages;
  final String? errorMessage;

  const PricingState({
    this.status = PricingStatus.initial,
    this.packages = const [],
    this.errorMessage,
  });

  PricingState copyWith({
    PricingStatus? status,
    List<PricingPackage>? packages,
    String? errorMessage,
    bool clearError = false,
  }) => PricingState(
    status: status ?? this.status,
    packages: packages ?? this.packages,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [status, packages, errorMessage];
}
