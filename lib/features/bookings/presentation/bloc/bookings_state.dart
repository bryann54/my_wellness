part of 'bookings_bloc.dart';

enum BookingsListStatus { initial, loading, loadingMore, loaded, error }

enum BookingDetailStatus { idle, loading, loaded, error }

enum CreateBookingStatus {
  idle,
  creating,
  created,
  awaitingPayment,
  awaitingConsent,
  completed,
  error,
}

enum ToastType { success, error, warning, info }

class BookingsState extends Equatable {
  final BookingsListStatus listStatus;
  final List<ServiceBooking> bookings;
  final String? nextCursor;
  final String? listError;

  final BookingDetailStatus detailStatus;
  final BookingTimeline? timeline;
  final String? detailError;
  final bool completing;
  final String? completeError;

  final CreateBookingStatus createStatus;
  final ServiceBooking? createdBooking;
  final bool stkLoading;
  final String? stkError;
  final Map<String, dynamic>? stkResult;
  final String? createError;

  final bool facilitiesLoading;
  final List<Facility> facilities;
  final String? facilitiesError;
  final bool creatingFacility;
  final Facility? createdFacility;

  final bool referralsLoading;
  final List<Referral> referrals;
  final String? referralsError;

  final bool referralDetailLoading;
  final Referral? referralDetail;
  final String? referralDetailError;

  final ToastType? toastType;
  final String? toastMessage;
  final int toastNonce;

  const BookingsState({
    this.listStatus = BookingsListStatus.initial,
    this.bookings = const [],
    this.nextCursor,
    this.listError,
    this.detailStatus = BookingDetailStatus.idle,
    this.timeline,
    this.detailError,
    this.completing = false,
    this.completeError,
    this.createStatus = CreateBookingStatus.idle,
    this.createdBooking,
    this.stkLoading = false,
    this.stkError,
    this.stkResult,
    this.createError,
    this.facilitiesLoading = false,
    this.facilities = const [],
    this.facilitiesError,
    this.creatingFacility = false,
    this.createdFacility,
    this.referralsLoading = false,
    this.referrals = const [],
    this.referralsError,
    this.referralDetailLoading = false,
    this.referralDetail,
    this.referralDetailError,
    this.toastType,
    this.toastMessage,
    this.toastNonce = 0,
  });

  bool get hasMore => nextCursor != null;

  BookingsState copyWith({
    BookingsListStatus? listStatus,
    List<ServiceBooking>? bookings,
    String? nextCursor,
    bool clearNextCursor = false,
    String? listError,
    bool clearListError = false,
    BookingDetailStatus? detailStatus,
    BookingTimeline? timeline,
    String? detailError,
    bool clearTimeline = false,
    bool clearDetailError = false,
    bool? completing,
    String? completeError,
    bool clearCompleteError = false,
    CreateBookingStatus? createStatus,
    ServiceBooking? createdBooking,
    bool clearCreatedBooking = false,
    bool? stkLoading,
    String? stkError,
    Map<String, dynamic>? stkResult,
    bool clearStkError = false,
    bool clearStkResult = false,
    String? createError,
    bool clearCreateError = false,
    bool? facilitiesLoading,
    List<Facility>? facilities,
    String? facilitiesError,
    bool clearFacilitiesError = false,
    bool? creatingFacility,
    Facility? createdFacility,
    bool clearCreatedFacility = false,
    bool? referralsLoading,
    List<Referral>? referrals,
    String? referralsError,
    bool clearReferralsError = false,
    bool? referralDetailLoading,
    Referral? referralDetail,
    bool clearReferralDetail = false,
    String? referralDetailError,
    bool clearReferralDetailError = false,
    ToastType? toastType,
    String? toastMessage,
    int? toastNonce,
    bool clearToast = false,
  }) {
    return BookingsState(
      listStatus: listStatus ?? this.listStatus,
      bookings: bookings ?? this.bookings,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      listError: clearListError ? null : (listError ?? this.listError),
      detailStatus: detailStatus ?? this.detailStatus,
      timeline: clearTimeline ? null : (timeline ?? this.timeline),
      detailError: clearDetailError ? null : (detailError ?? this.detailError),
      completing: completing ?? this.completing,
      completeError: clearCompleteError
          ? null
          : (completeError ?? this.completeError),
      createStatus: createStatus ?? this.createStatus,
      createdBooking: clearCreatedBooking
          ? null
          : (createdBooking ?? this.createdBooking),
      stkLoading: stkLoading ?? this.stkLoading,
      stkError: clearStkError ? null : (stkError ?? this.stkError),
      stkResult: clearStkResult ? null : (stkResult ?? this.stkResult),
      createError: clearCreateError ? null : (createError ?? this.createError),
      facilitiesLoading: facilitiesLoading ?? this.facilitiesLoading,
      facilities: facilities ?? this.facilities,
      facilitiesError: clearFacilitiesError
          ? null
          : (facilitiesError ?? this.facilitiesError),
      creatingFacility: creatingFacility ?? this.creatingFacility,
      createdFacility: clearCreatedFacility
          ? null
          : (createdFacility ?? this.createdFacility),
      referralsLoading: referralsLoading ?? this.referralsLoading,
      referrals: referrals ?? this.referrals,
      referralsError: clearReferralsError
          ? null
          : (referralsError ?? this.referralsError),
      referralDetailLoading:
          referralDetailLoading ?? this.referralDetailLoading,
      referralDetail: clearReferralDetail
          ? null
          : (referralDetail ?? this.referralDetail),
      referralDetailError: clearReferralDetailError
          ? null
          : (referralDetailError ?? this.referralDetailError),
      toastType: clearToast ? null : (toastType ?? this.toastType),
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      toastNonce: clearToast ? 0 : (toastNonce ?? this.toastNonce),
    );
  }

  @override
  List<Object?> get props => [
    listStatus,
    bookings,
    nextCursor,
    listError,
    detailStatus,
    timeline,
    detailError,
    completing,
    completeError,
    createStatus,
    createdBooking,
    stkLoading,
    stkError,
    stkResult,
    createError,
    facilitiesLoading,
    facilities,
    facilitiesError,
    creatingFacility,
    createdFacility,
    referralsLoading,
    referrals,
    referralsError,
    referralDetailLoading,
    referralDetail,
    referralDetailError,
    toastType,
    toastMessage,
    toastNonce,
  ];
}
