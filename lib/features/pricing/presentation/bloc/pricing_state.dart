part of 'pricing_bloc.dart';

enum PricingStatus { initial, loading, loaded, error }

class PricingState extends Equatable {
  final PricingStatus status;
  final PricingCatalog? catalog;
  final PricingQuote? quote;
  final bool quoteLoading;
  final String? quoteError;
  final PricingPayment? payment;
  final bool checkoutLoading;
  final String? checkoutError;
  final String? errorMessage;

  const PricingState({
    this.status = PricingStatus.initial,
    this.catalog,
    this.quote,
    this.quoteLoading = false,
    this.errorMessage,
    this.quoteError,
    this.payment,
    this.checkoutLoading = false,
    this.checkoutError,
  });

  PricingState copyWith({
    PricingStatus? status,
    PricingCatalog? catalog,
    PricingQuote? quote,
    bool? quoteLoading,
    String? errorMessage,
    String? quoteError,
    bool clearError = false,
    bool clearQuote = false,
    bool clearQuoteError = false,
    PricingPayment? payment,
    bool? checkoutLoading,
    String? checkoutError,
    bool clearPayment = false,
    bool clearCheckoutError = false,
  }) => PricingState(
    status: status ?? this.status,
    catalog: catalog ?? this.catalog,
    quote: clearQuote ? null : (quote ?? this.quote),
    quoteLoading: quoteLoading ?? this.quoteLoading,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    quoteError: clearQuoteError ? null : (quoteError ?? this.quoteError),
    payment: clearPayment ? null : (payment ?? this.payment),
    checkoutLoading: checkoutLoading ?? this.checkoutLoading,
    checkoutError: clearCheckoutError
        ? null
        : (checkoutError ?? this.checkoutError),
  );

  @override
  List<Object?> get props => [
    status,
    catalog,
    quote,
    quoteLoading,
    errorMessage,
    quoteError,
    payment,
    checkoutLoading,
    checkoutError,
  ];
}
