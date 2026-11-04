import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/features/bookings/domain/entities/booking_timeline.dart';
import 'package:my_wellness/features/bookings/domain/entities/facility.dart';
import 'package:my_wellness/features/bookings/domain/entities/referral.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/domain/repositories/bookings_repository.dart';
import 'package:my_wellness/features/bookings/domain/usecases/bookings_usecases.dart';

part 'bookings_event.dart';
part 'bookings_state.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  BookingsBloc({
    required GetMyBookingsUseCase getMyBookings,
    required GetBookingTimelineUseCase getTimeline,
    required CompleteBookingUseCase completeBooking,
    required CreateBookingUseCase createBooking,
    required PushStkForBookingUseCase pushStk,
    required MatchFacilitiesUseCase matchFacilities,
    required SearchFacilitiesUseCase searchFacilities,
    required CreateFacilityUseCase createFacility,
    required GetMyReferralsUseCase getMyReferrals,
    required GetReferralUseCase getReferral,
    required GenerateReferralFromSessionUseCase genFromSession,
    required GenerateReferralFromBpReadingUseCase genFromBp,
    required GenerateReferralFromBsReadingUseCase genFromBs,
  }) : _getMyBookings = getMyBookings,
       _getTimeline = getTimeline,
       _completeBooking = completeBooking,
       _createBooking = createBooking,
       _pushStk = pushStk,
       _matchFacilities = matchFacilities,
       _searchFacilities = searchFacilities,
       _createFacility = createFacility,
       _getMyReferrals = getMyReferrals,
       _getReferral = getReferral,
       _genFromSession = genFromSession,
       _genFromBp = genFromBp,
       _genFromBs = genFromBs,
       super(const BookingsState()) {
    on<LoadMyBookingsEvent>(_onLoadMyBookings, transformer: restartable());
    on<LoadMoreMyBookingsEvent>(_onLoadMore, transformer: droppable());
    on<SearchBookingsEvent>(_onSearch);
    on<LoadBookingTimelineEvent>(_onLoadTimeline, transformer: restartable());
    on<CompleteBookingEvent>(_onComplete, transformer: droppable());
    on<CreateBookingEvent>(_onCreate, transformer: droppable());
    on<PushStkForBookingEvent>(_onPushStk, transformer: droppable());
    on<AwaitBookingConsentEvent>(_onAwaitConsent);
    on<FinishBookingFlowEvent>(_onFinishFlow);
    on<ResetCreateBookingEvent>(_onResetCreate);
    on<ResetBookingsEvent>((_, emit) => emit(const BookingsState()));
    on<MatchFacilitiesEvent>(_onMatchFacilities, transformer: restartable());
    on<SearchFacilitiesEvent>(_onSearchFacilities, transformer: restartable());
    on<CreateFacilityEvent>(_onCreateFacility, transformer: droppable());
    on<LoadMyReferralsEvent>(_onLoadMyReferrals, transformer: restartable());
    on<LoadReferralEvent>(_onLoadReferral, transformer: restartable());
    on<GenerateReferralFromSessionEvent>(
      _onGenFromSession,
      transformer: restartable(),
    );
    on<GenerateReferralFromBpReadingEvent>(
      _onGenFromBp,
      transformer: restartable(),
    );
    on<GenerateReferralFromBsReadingEvent>(
      _onGenFromBs,
      transformer: restartable(),
    );
  }

  /// Builds a fresh instance with its dependencies from `getIt`. Use this
  /// everywhere instead of `getIt<BookingsBloc>()`.
  factory BookingsBloc.factory() => BookingsBloc(
    getMyBookings: getIt<GetMyBookingsUseCase>(),
    getTimeline: getIt<GetBookingTimelineUseCase>(),
    completeBooking: getIt<CompleteBookingUseCase>(),
    createBooking: getIt<CreateBookingUseCase>(),
    pushStk: getIt<PushStkForBookingUseCase>(),
    matchFacilities: getIt<MatchFacilitiesUseCase>(),
    searchFacilities: getIt<SearchFacilitiesUseCase>(),
    createFacility: getIt<CreateFacilityUseCase>(),
    getMyReferrals: getIt<GetMyReferralsUseCase>(),
    getReferral: getIt<GetReferralUseCase>(),
    genFromSession: getIt<GenerateReferralFromSessionUseCase>(),
    genFromBp: getIt<GenerateReferralFromBpReadingUseCase>(),
    genFromBs: getIt<GenerateReferralFromBsReadingUseCase>(),
  );

  final GetMyBookingsUseCase _getMyBookings;
  final GetBookingTimelineUseCase _getTimeline;
  final CompleteBookingUseCase _completeBooking;
  final CreateBookingUseCase _createBooking;
  final PushStkForBookingUseCase _pushStk;
  final MatchFacilitiesUseCase _matchFacilities;
  final SearchFacilitiesUseCase _searchFacilities;
  final CreateFacilityUseCase _createFacility;
  final GetMyReferralsUseCase _getMyReferrals;
  final GetReferralUseCase _getReferral;
  final GenerateReferralFromSessionUseCase _genFromSession;
  final GenerateReferralFromBpReadingUseCase _genFromBp;
  final GenerateReferralFromBsReadingUseCase _genFromBs;

  BookingsState _toasted(
    BookingsState base,
    BookingToastType type,
    String message, {
    bool isKey = false,
  }) => base.copyWith(
    toastType: type,
    toastMessage: message,
    toastIsKey: isKey,
    toastNonce: base.toastNonce + 1,
  );

  Future<void> _onLoadMyBookings(
    LoadMyBookingsEvent event,
    Emitter<BookingsState> emit,
  ) async {
    if (state.listStatus == BookingsListStatus.loaded && !event.refresh) {
      return;
    }
    if (state.listStatus == BookingsListStatus.loading) return;

    emit(
      state.copyWith(
        listStatus: BookingsListStatus.loading,
        clearListError: true,
      ),
    );
    final result = await _getMyBookings();
    result.fold(
      (failure) => emit(
        state.copyWith(
          listStatus: BookingsListStatus.error,
          listError: mapFailure(failure),
        ),
      ),
      (page) => emit(
        state.copyWith(
          listStatus: BookingsListStatus.loaded,
          bookings: page.items,
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
        ),
      ),
    );
  }

  Future<void> _onLoadTimeline(
    LoadBookingTimelineEvent event,
    Emitter<BookingsState> emit,
  ) async {
    if (state.detailStatus == BookingDetailStatus.loaded &&
        state.timeline?.booking.id == event.bookingId) {
      return;
    }
    emit(
      state.copyWith(
        detailStatus: BookingDetailStatus.loading,
        clearDetailError: true,
        clearTimeline: true,
      ),
    );
    final result = await _getTimeline(event.bookingId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          detailStatus: BookingDetailStatus.error,
          detailError: mapFailure(failure),
        ),
      ),
      (timeline) => emit(
        state.copyWith(
          detailStatus: BookingDetailStatus.loaded,
          timeline: timeline,
        ),
      ),
    );
  }

  Future<void> _onComplete(
    CompleteBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    if (state.completing) return;
    emit(state.copyWith(completing: true));
    final result = await _completeBooking(event.bookingId);
    result.fold(
      (failure) => emit(
        _toasted(
          state.copyWith(completing: false),
          BookingToastType.error,
          mapFailure(failure),
        ),
      ),
      (updated) {
        final next = state.bookings
            .map((b) => b.id == updated.id ? updated : b)
            .toList(growable: false);
        emit(
          _toasted(
            state.copyWith(completing: false, bookings: next),
            BookingToastType.success,
            'bookings.toast.completed',
            isKey: true,
          ),
        );
        final referral = state.referralDetail;
        if (referral != null && referral.booking?.id == updated.id) {
          add(LoadReferralEvent(referral.id, silent: true));
        }
        if (state.referrals.isNotEmpty) {
          add(const LoadMyReferralsEvent(refresh: true));
        }
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreMyBookingsEvent event,
    Emitter<BookingsState> emit,
  ) async {
    if (state.nextCursor == null ||
        state.listStatus != BookingsListStatus.loaded) {
      return;
    }
    emit(state.copyWith(listStatus: BookingsListStatus.loadingMore));
    final result = await _getMyBookings(cursor: state.nextCursor);
    result.fold(
      (failure) => emit(
        _toasted(
          state.copyWith(listStatus: BookingsListStatus.loaded),
          BookingToastType.error,
          mapFailure(failure),
        ),
      ),
      (page) => emit(
        state.copyWith(
          listStatus: BookingsListStatus.loaded,
          bookings: [...state.bookings, ...page.items],
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
        ),
      ),
    );
  }

  void _onSearch(SearchBookingsEvent event, Emitter<BookingsState> emit) {
    emit(state.copyWith(searchQuery: event.query.trim()));
  }

  Future<void> _onCreate(
    CreateBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    if (state.createStatus == CreateBookingStatus.creating) return;
    emit(
      state.copyWith(
        createStatus: CreateBookingStatus.creating,
        clearCreatedBooking: true,
        clearStkError: true,
        clearStkResult: true,
      ),
    );
    final result = await _createBooking(event.params);
    result.fold(
      (failure) => emit(
        _toasted(
          state.copyWith(createStatus: CreateBookingStatus.error),
          BookingToastType.error,
          mapFailure(failure),
        ),
      ),
      (booking) {
        emit(
          state.copyWith(
            createStatus: CreateBookingStatus.created,
            createdBooking: booking,
          ),
        );
        final referral = state.referralDetail;
        if (referral != null && booking.referralId == referral.id) {
          add(LoadReferralEvent(referral.id, silent: true));
        }
        if (state.listStatus == BookingsListStatus.loaded) {
          add(const LoadMyBookingsEvent(refresh: true));
        }
        if (state.referrals.isNotEmpty) {
          add(const LoadMyReferralsEvent(refresh: true));
        }
      },
    );
  }

  Future<void> _onPushStk(
    PushStkForBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    if (state.stkLoading) return;
    emit(state.copyWith(stkLoading: true, clearStkError: true));
    final result = await _pushStk(event.params);
    result.fold(
      (failure) => emit(
        state.copyWith(stkLoading: false, stkError: mapFailure(failure)),
      ),
      (payload) => emit(
        state.copyWith(
          stkLoading: false,
          stkResult: payload,
          createStatus: CreateBookingStatus.awaitingPayment,
        ),
      ),
    );
  }

  void _onAwaitConsent(
    AwaitBookingConsentEvent event,
    Emitter<BookingsState> emit,
  ) => emit(state.copyWith(createStatus: CreateBookingStatus.awaitingConsent));

  void _onFinishFlow(
    FinishBookingFlowEvent event,
    Emitter<BookingsState> emit,
  ) => emit(state.copyWith(createStatus: CreateBookingStatus.completed));

  void _onResetCreate(
    ResetCreateBookingEvent event,
    Emitter<BookingsState> emit,
  ) {
    emit(
      state.copyWith(
        createStatus: CreateBookingStatus.idle,
        clearCreatedBooking: true,
        clearStkError: true,
        clearStkResult: true,
        stkLoading: false,
      ),
    );
  }

  Future<void> _onMatchFacilities(
    MatchFacilitiesEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(
      state.copyWith(
        facilitiesLoading: true,
        clearFacilitiesError: true,
        clearCreatedFacility: true,
      ),
    );
    final result = await _matchFacilities(
      serviceType: event.serviceType,
      userLat: event.userLat,
      userLng: event.userLng,
      town: event.town,
      county: event.county,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          facilitiesLoading: false,
          facilitiesError: mapFailure(failure),
        ),
      ),
      (list) =>
          emit(state.copyWith(facilitiesLoading: false, facilities: list)),
    );
  }

  Future<void> _onSearchFacilities(
    SearchFacilitiesEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(state.copyWith(facilitiesLoading: true, clearFacilitiesError: true));
    final result = await _searchFacilities(event.query);
    result.fold(
      (failure) => emit(
        state.copyWith(
          facilitiesLoading: false,
          facilitiesError: mapFailure(failure),
        ),
      ),
      (list) =>
          emit(state.copyWith(facilitiesLoading: false, facilities: list)),
    );
  }

  Future<void> _onCreateFacility(
    CreateFacilityEvent event,
    Emitter<BookingsState> emit,
  ) async {
    if (state.creatingFacility) return;
    emit(
      state.copyWith(
        creatingFacility: true,
        clearFacilitiesError: true,
        clearCreatedFacility: true,
      ),
    );
    final result = await _createFacility(event.params);
    result.fold(
      (failure) => emit(
        state.copyWith(
          creatingFacility: false,
          facilitiesError: mapFailure(failure),
        ),
      ),
      (facility) => emit(
        state.copyWith(
          creatingFacility: false,
          createdFacility: facility,
          facilities: [facility, ...state.facilities],
        ),
      ),
    );
  }

  Future<void> _onLoadMyReferrals(
    LoadMyReferralsEvent event,
    Emitter<BookingsState> emit,
  ) async {
    if (!event.refresh && state.referrals.isNotEmpty) return;
    emit(state.copyWith(referralsLoading: true, clearReferralsError: true));
    final result = await _getMyReferrals();
    result.fold(
      (failure) => emit(
        state.copyWith(
          referralsLoading: false,
          referralsError: mapFailure(failure),
        ),
      ),
      (list) => emit(state.copyWith(referralsLoading: false, referrals: list)),
    );
  }

  Future<void> _onLoadReferral(
    LoadReferralEvent event,
    Emitter<BookingsState> emit,
  ) async {
    if (!event.silent) {
      emit(
        state.copyWith(
          referralDetailLoading: true,
          clearReferralDetail: true,
          clearReferralDetailError: true,
        ),
      );
    }
    final result = await _getReferral(event.referralId);
    result.fold(
      (failure) {
        if (event.silent) return;
        emit(
          state.copyWith(
            referralDetailLoading: false,
            referralDetailError: mapFailure(failure),
          ),
        );
      },
      (referral) => emit(
        state.copyWith(referralDetailLoading: false, referralDetail: referral),
      ),
    );
  }

  Future<void> _onGenFromSession(
    GenerateReferralFromSessionEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(
      state.copyWith(
        referralDetailLoading: true,
        clearReferralDetailError: true,
      ),
    );
    final result = await _genFromSession(
      event.sessionId,
      userLat: event.userLat,
      userLng: event.userLng,
      facilityId: event.facilityId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          referralDetailLoading: false,
          referralDetailError: mapFailure(failure),
        ),
      ),
      (referral) => emit(
        state.copyWith(referralDetailLoading: false, referralDetail: referral),
      ),
    );
  }

  Future<void> _onGenFromBp(
    GenerateReferralFromBpReadingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(
      state.copyWith(
        referralDetailLoading: true,
        clearReferralDetailError: true,
      ),
    );
    final result = await _genFromBp(
      event.readingId,
      userLat: event.userLat,
      userLng: event.userLng,
      facilityId: event.facilityId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          referralDetailLoading: false,
          referralDetailError: mapFailure(failure),
        ),
      ),
      (referral) => emit(
        state.copyWith(referralDetailLoading: false, referralDetail: referral),
      ),
    );
  }

  Future<void> _onGenFromBs(
    GenerateReferralFromBsReadingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    emit(
      state.copyWith(
        referralDetailLoading: true,
        clearReferralDetailError: true,
      ),
    );
    final result = await _genFromBs(
      event.readingId,
      userLat: event.userLat,
      userLng: event.userLng,
      facilityId: event.facilityId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          referralDetailLoading: false,
          referralDetailError: mapFailure(failure),
        ),
      ),
      (referral) => emit(
        state.copyWith(referralDetailLoading: false, referralDetail: referral),
      ),
    );
  }
}
