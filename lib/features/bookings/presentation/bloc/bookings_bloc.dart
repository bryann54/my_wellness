import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/bookings/domain/entities/booking_timeline.dart';
import 'package:my_wellness/features/bookings/domain/entities/facility.dart';
import 'package:my_wellness/features/bookings/domain/entities/referral.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/domain/repositories/bookings_repository.dart';
import 'package:my_wellness/features/bookings/domain/usecases/bookings_usecases.dart';

part 'bookings_event.dart';
part 'bookings_state.dart';

@injectable
class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
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
    on<LoadBookingTimelineEvent>(_onLoadTimeline, transformer: restartable());
    on<CompleteBookingEvent>(_onComplete, transformer: droppable());
    on<CreateBookingEvent>(_onCreate, transformer: droppable());
    on<PushStkForBookingEvent>(_onPushStk, transformer: droppable());
    on<AwaitBookingConsentEvent>(_onAwaitConsent);
    on<FinishBookingFlowEvent>(_onFinishFlow);
    on<ResetCreateBookingEvent>(_onResetCreate);
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

  BookingsState _withToast(
    BookingsState s, {
    required ToastType type,
    required String message,
  }) {
    return s.copyWith(
      toastType: type,
      toastMessage: message,
      toastNonce: s.toastNonce + 1,
    );
  }

  Future<void> _onLoadMyBookings(
    LoadMyBookingsEvent event,
    Emitter<BookingsState> emit,
  ) async {
    if (state.listStatus == BookingsListStatus.loaded && !event.refresh) {
      return;
    }
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
        state.copyWith(
          listStatus: BookingsListStatus.loaded,
          listError: mapFailure(failure),
        ),
      ),
      (page) => emit(
        state.copyWith(
          listStatus: BookingsListStatus.loaded,
          bookings: [...state.bookings, ...page.items],
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
          clearListError: true,
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
    emit(state.copyWith(completing: true, clearCompleteError: true));
    final result = await _completeBooking(event.bookingId);
    result.fold(
      (failure) {
        final message = mapFailure(failure);
        emit(
          _withToast(
            state.copyWith(completing: false, completeError: message),
            type: ToastType.error,
            message: message,
          ),
        );
      },
      (updated) {
        final next = state.bookings
            .map((b) => b.id == updated.id ? updated : b)
            .toList(growable: false);
        emit(
          _withToast(
            state.copyWith(completing: false, bookings: next),
            type: ToastType.success,
            message: 'Booking marked as completed.',
          ),
        );
        final current = state.timeline;
        if (current != null && current.booking.id == updated.id) {
          add(LoadBookingTimelineEvent(updated.id));
        }
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

  Future<void> _onCreate(
    CreateBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    if (state.createStatus == CreateBookingStatus.creating) return;
    emit(
      state.copyWith(
        createStatus: CreateBookingStatus.creating,
        clearCreateError: true,
        clearCreatedBooking: true,
        clearStkError: true,
        clearStkResult: true,
      ),
    );
    final result = await _createBooking(event.params);
    result.fold(
      (failure) {
        final message = mapFailure(failure);
        emit(
          _withToast(
            state.copyWith(
              createStatus: CreateBookingStatus.error,
              createError: message,
            ),
            type: ToastType.error,
            message: message,
          ),
        );
      },
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
      (failure) {
        final message = mapFailure(failure);
        emit(
          _withToast(
            state.copyWith(stkLoading: false, stkError: message),
            type: ToastType.error,
            message: message,
          ),
        );
      },
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
        clearCreateError: true,
        clearStkError: true,
        clearStkResult: true,
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
    emit(
      state.copyWith(
        facilitiesLoading: true,
        facilities: const [],
        clearFacilitiesError: true,
      ),
    );
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
    if (state.referralsLoading) return;
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
    if (!event.silent &&
        state.referralDetail?.id == event.referralId &&
        state.referralDetailLoading == false &&
        state.referralDetailError == null) {
      return;
    }
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
