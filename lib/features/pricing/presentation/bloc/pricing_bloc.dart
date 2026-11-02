import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/pricing/domain/entities/payment_destination.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_catalog.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_package.dart';
import 'package:my_wellness/features/pricing/domain/usecases/get_pricing_packages.dart';

part 'pricing_event.dart';
part 'pricing_state.dart';

@injectable
class PricingBloc extends Bloc<PricingEvent, PricingState> {
  final GetPricingCatalogUseCase _getCatalog;
  final GetPricingQuoteUseCase _getQuote;
  final CheckoutPricingSelectionUseCase _checkout;
  final GetPricingPackagesUseCase _getPackages;
  final StkPushUseCase _stkPush;
  final GetMyPaymentsUseCase _getMyPayments;
  final GetUnlockedCategoriesUseCase _getUnlockedCategories;
  final HasVitalsLoggingAccessUseCase _hasVitalsAccess;

  Timer? _paymentPollTimer;
  Timer? _accessPollTimer;
  Timer? _softTimeoutTimer;

  PricingBloc(
    this._getCatalog,
    this._getQuote,
    this._checkout,
    this._getPackages,
    this._stkPush,
    this._getMyPayments,
    this._getUnlockedCategories,
    this._hasVitalsAccess,
  ) : super(const PricingState()) {
    on<LoadPricingPackagesEvent>(_load, transformer: droppable());
    on<LoadPricingPackagesForCategoryEvent>(_loadCategory);
    on<QuotePricingSelectionEvent>(_quote, transformer: restartable());
    on<CheckoutPricingSelectionEvent>(_onCheckout, transformer: droppable());
    on<StkPushEvent>(_onStkPush, transformer: droppable());
    on<PollPaymentStatusEvent>(_onPollPayment);
    on<PollModuleAccessEvent>(_onPollAccess);
    on<CancelPollingEvent>(_onCancelPolling);
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }

  void _cancelTimers() {
    _paymentPollTimer?.cancel();
    _accessPollTimer?.cancel();
    _softTimeoutTimer?.cancel();
    _paymentPollTimer = null;
    _accessPollTimer = null;
    _softTimeoutTimer = null;
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

  Future<void> _loadCategory(
    LoadPricingPackagesForCategoryEvent event,
    Emitter<PricingState> emit,
  ) async {
    emit(
      state.copyWith(legacyCategory: event.category, clearLegacyPackages: true),
    );
    final result = await _getPackages(
      category: event.category,
      refresh: event.refresh,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: mapFailure(failure),
          clearLegacyPackages: true,
        ),
      ),
      (packages) => emit(
        state.copyWith(
          legacyCategory: event.category,
          legacyPackages: packages,
        ),
      ),
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
        clearDestination: true,
        lastQuotedSelection: event.selection,
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
    final selection = state.lastQuotedSelection ?? event.selection;
    final idempotencyKey = event.idempotencyKey ?? const Uuid().v4();

    final result = await _checkout(
      selection: selection,
      phone: event.phone,
      idempotencyKey: idempotencyKey,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          checkoutLoading: false,
          checkoutError: mapFailure(failure),
        ),
      ),
      (payment) {
        final destination = resolvePaymentDestination(
          serviceIds: _serviceIdsOf(selection),
          bundleId: selection['bundle']?.toString(),
        );
        emit(
          state.copyWith(
            checkoutLoading: false,
            payment: payment,
            destination: destination,
            paymentPollStatus: PaymentPollStatus.waiting,
            accessReady: false,
          ),
        );
        add(PollPaymentStatusEvent(paymentId: payment.id));
      },
    );
  }

  Future<void> _onStkPush(
    StkPushEvent event,
    Emitter<PricingState> emit,
  ) async {
    emit(
      state.copyWith(
        checkoutLoading: true,
        clearCheckoutError: true,
        clearPayment: true,
      ),
    );
    final result = await _stkPush(
      phone: event.phone,
      amount: event.amount,
      serviceType: event.serviceType,
      idempotencyKey: event.idempotencyKey,
      sessionId: event.sessionId,
      bookingId: event.bookingId,
      invoiceId: event.invoiceId,
      packageId: event.packageId,
      age: event.age,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          checkoutLoading: false,
          checkoutError: mapFailure(failure),
        ),
      ),
      (payment) {
        final destination = resolvePackageDestination(
          categories: const [],
          returnToSessionId: event.sessionId,
        );
        emit(
          state.copyWith(
            checkoutLoading: false,
            payment: payment,
            destination: destination,
            paymentPollStatus: PaymentPollStatus.waiting,
            accessReady: false,
          ),
        );
        add(PollPaymentStatusEvent(paymentId: payment.id));
      },
    );
  }

  Set<String> _serviceIdsOf(Map<String, dynamic> selection) {
    final bundle = selection['bundle']?.toString();
    if (bundle == 'all_in_one') return const {'all_in_one_services'};
    if (bundle == 'cm') return const {'cancer', 'metabolic'};
    if (bundle == 'cn') return const {'cancer', 'mental'};
    if (bundle == 'cw') return const {'cancer', 'women'};
    if (bundle == 'cs') return const {'cancer', 'sexual'};
    final raw = selection['service_ids'];
    if (raw is List) {
      return raw.map((e) => e.toString()).toSet();
    }
    return const {};
  }

  Future<void> _onPollPayment(
    PollPaymentStatusEvent event,
    Emitter<PricingState> emit,
  ) async {
    _paymentPollTimer?.cancel();
    _softTimeoutTimer?.cancel();
    _softTimeoutTimer = Timer(const Duration(minutes: 2), () {
      if (emit.isDone) return;
      if (state.paymentPollStatus == PaymentPollStatus.waiting) {
        emit(
          state.copyWith(paymentPollStatus: PaymentPollStatus.waitingTooLong),
        );
      }
    });

    Future<void> tick() async {
      if (emit.isDone) return;
      final res = await _getMyPayments();
      res.fold((_) {}, (payments) {
        final match = payments.firstWhere(
          (p) => p.id == event.paymentId,
          orElse: () => const PricingPayment(
            id: '',
            status: 'pending',
            phoneNumber: '',
            amountKes: 0,
          ),
        );
        if (match.id.isEmpty) return;
        if (match.isSuccess) {
          _paymentPollTimer?.cancel();
          _softTimeoutTimer?.cancel();
          emit(
            state.copyWith(
              paymentPollStatus: PaymentPollStatus.success,
              payment: match,
            ),
          );
          final destination = state.destination;
          if (destination != null && !destination.requirement.isEmpty) {
            add(
              PollModuleAccessEvent(
                categories: destination.requirement.categories,
                waitVitals: destination.requirement.waitVitals,
              ),
            );
          } else {
            emit(state.copyWith(accessReady: true));
          }
          return;
        }
        if (match.isFailed) {
          _paymentPollTimer?.cancel();
          _softTimeoutTimer?.cancel();
          emit(
            state.copyWith(
              paymentPollStatus: PaymentPollStatus.failed,
              payment: match,
            ),
          );
          return;
        }
      });
      if (emit.isDone) return;
      if (state.paymentPollStatus == PaymentPollStatus.success ||
          state.paymentPollStatus == PaymentPollStatus.failed) {
        return;
      }
      _paymentPollTimer = Timer(const Duration(seconds: 3), tick);
    }

    await tick();
  }

  Future<void> _onPollAccess(
    PollModuleAccessEvent event,
    Emitter<PricingState> emit,
  ) async {
    _accessPollTimer?.cancel();

    const maxTicks = 20;
    var tick = 0;

    Future<void> check() async {
      if (emit.isDone) return;
      tick++;
      var ready = true;
      if (event.categories.isNotEmpty) {
        final res = await _getUnlockedCategories();
        final unlocked = res.fold((_) => const <String>{}, (set) => set);
        ready = event.categories.every(unlocked.contains);
      }
      if (ready && event.waitVitals) {
        final vitalsRes = await _hasVitalsAccess();
        ready = vitalsRes.fold((_) => false, (ok) => ok);
      }
      if (ready) {
        _accessPollTimer?.cancel();
        emit(state.copyWith(accessReady: true));
        return;
      }
      if (tick >= maxTicks) {
        _accessPollTimer?.cancel();
        return;
      }
      _accessPollTimer = Timer(const Duration(seconds: 1), check);
    }

    await check();
  }

  void _onCancelPolling(CancelPollingEvent event, Emitter<PricingState> emit) {
    _cancelTimers();
  }
}
