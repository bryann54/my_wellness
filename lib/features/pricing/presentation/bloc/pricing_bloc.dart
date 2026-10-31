import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_catalog.dart';
import 'package:my_wellness/features/pricing/domain/usecases/get_pricing_packages.dart';

part 'pricing_event.dart';
part 'pricing_state.dart';

@injectable
class PricingBloc extends Bloc<PricingEvent, PricingState> {
  final GetPricingCatalogUseCase _getCatalog;
  final GetPricingQuoteUseCase _getQuote;
  final CheckoutPricingSelectionUseCase _checkout;

  PricingBloc(this._getCatalog, this._getQuote, this._checkout)
    : super(const PricingState()) {
    on<LoadPricingPackagesEvent>(_load);
    on<QuotePricingSelectionEvent>(_quote, transformer: restartable());
    on<CheckoutPricingSelectionEvent>(_onCheckout, transformer: droppable());
  }

  Future<void> _load(
    LoadPricingPackagesEvent event,
    Emitter<PricingState> emit,
  ) async {
    if (state.status == PricingStatus.loaded && !event.refresh) return;
    if (event.refresh || state.catalog == null) {
      emit(state.copyWith(status: PricingStatus.loading, clearError: true));
    }
    final result = await _getCatalog(refresh: event.refresh);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PricingStatus.error,
          errorMessage: mapFailure(failure),
        ),
      ),
      (catalog) =>
          emit(state.copyWith(status: PricingStatus.loaded, catalog: catalog)),
    );
  }

  Future<void> _quote(
    QuotePricingSelectionEvent event,
    Emitter<PricingState> emit,
  ) async {
    emit(
      state.copyWith(
        quoteLoading: true,
        clearQuoteError: true,
        clearQuote: true,
        clearPayment: true,
        clearCheckoutError: true,
      ),
    );
    final result = await _getQuote(event.selection);
    result.fold(
      (failure) => emit(
        state.copyWith(
          quoteLoading: false,
          quoteError: mapFailure(failure),
          clearQuote: true,
        ),
      ),
      (quote) => emit(state.copyWith(quoteLoading: false, quote: quote)),
    );
  }

  Future<void> _onCheckout(
    CheckoutPricingSelectionEvent event,
    Emitter<PricingState> emit,
  ) async {
    emit(
      state.copyWith(
        checkoutLoading: true,
        clearCheckoutError: true,
        clearPayment: true,
      ),
    );
    final result = await _checkout(
      selection: event.selection,
      phone: event.phone,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          checkoutLoading: false,
          checkoutError: mapFailure(failure),
        ),
      ),
      (payment) =>
          emit(state.copyWith(checkoutLoading: false, payment: payment)),
    );
  }
}
