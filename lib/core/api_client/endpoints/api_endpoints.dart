class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ────────────────────────────────────────────────────────────────────
  static const String authLogin = '/api/auth/login/';
  static const String authLogout = '/api/auth/logout/';
  static const String authLogoutAll = '/api/auth/logout-all/';
  static const String authSignup = '/api/auth/signup/';
  static const String authSignupConfirm = '/api/auth/signup/confirm/';
  static const String authSignupPhoneConfirm =
      '/api/auth/signup/phone/confirm/';
  static const String authSignupPhoneResend = '/api/auth/signup/phone/resend/';
  static const String authSignupResend = '/api/auth/signup/resend/';
  static const String authTokenRefresh = '/api/auth/token/refresh/';
  static const String authPasswordResetRequest =
      '/api/auth/password-reset/request/';
  static const String authPasswordResetConfirm =
      '/api/auth/password-reset/confirm/';

  // ── Accounts (self-service) ─────────────────────────────────────────────────
  static const String analyticsOptOut = '/api/auth/analytics-opt-out/';
  static const String changePassword = '/api/auth/change-password/';
  static const String deleteAccount = '/api/auth/delete-account/';
  static const String deleteAccountCancel = '/api/auth/delete-account/cancel/';
  static const String deleteAccountStatus = '/api/auth/delete-account/status/';
  static const String exportData = '/api/auth/export-data/';
  static const String shaConsent = '/api/auth/sha-consent/';

  // ── MFA ─────────────────────────────────────────────────────────────────────
  static const String mfaConfirm = '/api/auth/mfa/confirm/';
  static const String mfaDisable = '/api/auth/mfa/disable/';
  static const String mfaEnroll = '/api/auth/mfa/enroll/';
  static const String mfaRegenerateBackupCodes =
      '/api/auth/mfa/regenerate-backup-codes/';
  static const String mfaStatus = '/api/auth/mfa/status/';
  static const String mfaVerify = '/api/auth/mfa/verify/';

  // ── OTP ─────────────────────────────────────────────────────────────────────
  static const String otpRequest = '/api/otp/request/';
  static const String otpVerify = '/api/otp/verify/';
  static const String otpPhoneRequest = '/api/otp/phone/request/';
  static const String otpPhoneVerify = '/api/otp/phone/verify/';
  static const String otpPasswordResetRequest =
      '/api/otp/password-reset/request/';
  static const String otpPasswordResetConfirm =
      '/api/otp/password-reset/confirm/';

  // ── Assessments ─────────────────────────────────────────────────────────────
  static const String assessments = '/api/assessments/';
  static const String dashboard = '/api/dashboard/';
  static String assessmentDetail(String slug) => '/api/assessments/$slug/';
  static String assessmentCanStart(String slug) =>
      '/api/assessments/$slug/can-start/';
  static String assessmentStartSession(String slug) =>
      '/api/assessments/$slug/session/';
  static String assessmentAnswers(String slug, String sessionId) =>
      '/api/assessments/$slug/session/$sessionId/answers/';
  static String assessmentBmiMetrics(String slug, String sessionId) =>
      '/api/assessments/$slug/session/$sessionId/bmi-metrics/';
  static String assessmentReport(String slug, String sessionId) =>
      '/api/assessments/$slug/session/$sessionId/report/';
  static String assessmentReportEmail(String slug, String sessionId) =>
      '/api/assessments/$slug/session/$sessionId/report/email/';
  static String assessmentReportEmailPrefill(String slug, String sessionId) =>
      '/api/assessments/$slug/session/$sessionId/report/email-prefill/';
  static String assessmentScore(String slug, String sessionId) =>
      '/api/assessments/$slug/session/$sessionId/score/';

  // ── Bookings ────────────────────────────────────────────────────────────────
  static const String bookings = '/api/bookings/';
  static const String bookingsFacility = '/api/bookings/facility/';
  static const String bookingsMine = '/api/bookings/mine/';
  static const String bookingsMineAssigned = '/api/bookings/mine-assigned/';
  static const String bookingsUnclaimed = '/api/bookings/unclaimed/';
  static String bookingCheckIn(String bookingId) =>
      '/api/bookings/$bookingId/check-in/';
  static String bookingClaim(String bookingId) =>
      '/api/bookings/$bookingId/claim/';
  static String bookingComplete(String bookingId) =>
      '/api/bookings/$bookingId/complete/';
  static String bookingFollowUp(String bookingId) =>
      '/api/bookings/$bookingId/follow-up/';
  static String bookingTimeline(String bookingId) =>
      '/api/bookings/$bookingId/timeline/';
  static String bookingUnclaim(String bookingId) =>
      '/api/bookings/$bookingId/unclaim/';
  static String bookingFacilityStatus(String bookingId) =>
      '/api/bookings/facility/$bookingId/status/';

  // ── Doctor Invites ──────────────────────────────────────────────────────────
  static String doctorInvite(String token) => '/api/doctor-invites/$token/';
  static const String doctorInviteRedeem = '/api/doctor-invites/redeem/';

  // ── Invite Codes ────────────────────────────────────────────────────────────
  static const String inviteCodesInvoices = '/api/invite-codes/invoices/';
  static const String inviteCodesMyCompanyAdminFlag =
      '/api/invite-codes/my-company-admin-flag/';
  static const String inviteCodesMyPackages = '/api/invite-codes/my-packages/';
  static String inviteCode(String token) => '/api/invite-codes/$token/';
  static String inviteCodeRedeem(String token) =>
      '/api/invite-codes/$token/redeem/';
  static String inviteCodeInviteByEmail(String inviteCodeId) =>
      '/api/invite-codes/$inviteCodeId/invite-by-email/';
  static String inviteCodeReports(String inviteCodeId) =>
      '/api/invite-codes/$inviteCodeId/reports/';

  // ── Payments ────────────────────────────────────────────────────────────────
  static const String paymentsMine = '/api/payments/mine/';
  static const String paymentsModuleAccess = '/api/payments/module-access/';
  static const String paymentsPackages = '/api/payments/packages/';
  static const String paymentsC2bConfirmation =
      '/api/payments/c2b/confirmation/';
  static const String paymentsC2bValidation = '/api/payments/c2b/validation/';
  static const String paymentsMpesaCallback = '/api/payments/mpesa-callback/';

  // ── Health Profile ──────────────────────────────────────────────────────────
  static const String healthProfile = '/api/health-profile/';

  // ── Health Exchange ─────────────────────────────────────────────────────────
  static const String healthExchangeClinicVisitNotifications =
      '/api/health-exchange/clinic-visit-notifications/';
  static const String healthExchangeMySummary =
      '/api/health-exchange/my-summary/';
  static const String healthExchangeShaEligibility =
      '/api/health-exchange/sha-eligibility/';

  // ── Chatbot ─────────────────────────────────────────────────────────────────
  static const String chatbotMessage = '/api/chatbot/message/';

  // ── Geography ───────────────────────────────────────────────────────────────
  static const String geographyConstituencies =
      '/api/geography/constituencies/';
  static const String geographyCounties = '/api/geography/counties/';
  static const String geographySubCounties = '/api/geography/sub-counties/';
  static const String geographyWards = '/api/geography/wards/';

  // ── Notifications (Push) ────────────────────────────────────────────────────
  static const String pushSubscribe = '/api/push/subscribe/';
  static const String pushVapidPublicKey = '/api/push/vapid-public-key/';
  static const String pushPartnerNotifications =
      '/api/push/partner-notifications/';
  static const String pushPartnerNotificationsMine =
      '/api/push/partner-notifications/mine/';
  static String pushPartnerNotification(String notificationId) =>
      '/api/push/partner-notifications/$notificationId/';
  static String pushPartnerNotificationLookup(String token) =>
      '/api/push/partner-notifications/lookup/$token/';
}
