part of 'pricing_bloc.dart';

enum PricingStatus { initial, loading, loaded, error }

enum PaymentPollStatus { notStarted, waiting, success, failed, waitingTooLong }

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

  final List<PricingPackage>? legacyPackages;
  final String? legacyCategory;

  final PaymentPollStatus paymentPollStatus;
  final bool accessReady;
  final PaymentDestinationResult? destination;

  final Map<String, dynamic>? lastQuotedSelection;

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
    this.legacyPackages,
    this.legacyCategory,
    this.paymentPollStatus = PaymentPollStatus.notStarted,
    this.accessReady = false,
    this.destination,
    this.lastQuotedSelection,
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
    List<PricingPackage>? legacyPackages,
    String? legacyCategory,
    bool clearLegacyPackages = false,
    PaymentPollStatus? paymentPollStatus,
    bool? accessReady,
    PaymentDestinationResult? destination,
    bool clearDestination = false,
    Map<String, dynamic>? lastQuotedSelection,
    bool clearLastQuotedSelection = false,
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
    legacyPackages: clearLegacyPackages
        ? null
        : (legacyPackages ?? this.legacyPackages),
    legacyCategory: clearLegacyPackages
        ? null
        : (legacyCategory ?? this.legacyCategory),
    paymentPollStatus: paymentPollStatus ?? this.paymentPollStatus,
    accessReady: accessReady ?? this.accessReady,
    destination: clearDestination ? null : (destination ?? this.destination),
    lastQuotedSelection: clearLastQuotedSelection
        ? null
        : (lastQuotedSelection ?? this.lastQuotedSelection),
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
    legacyPackages,
    legacyCategory,
    paymentPollStatus,
    accessReady,
    destination,
    lastQuotedSelection,
  ];
}
