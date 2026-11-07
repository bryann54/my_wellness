import 'package:auto_route/auto_route.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: AuthRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: ForgotPasswordRoute.page),

    AutoRoute(
      page: MainRoute.page,
      children: [
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: AssessmentsListRoute.page),
        AutoRoute(page: AppointmentsRoute.page),
        AutoRoute(page: AccountRoute.page),
      ],
    ),

    AutoRoute(page: VitalsRoute.page),
    AutoRoute(page: VitalsRouteRoute.page),
    AutoRoute(page: NotificationsRoute.page),
    AutoRoute(page: MedicationsRoute.page),
    AutoRoute(page: MyHealthRoute.page),
    AutoRoute(page: AddMedicationRoute.page),

    AutoRoute(page: VitalsCaptureIntroRoute.page),
    AutoRoute(page: VitalsPathwayRoute.page),
    AutoRoute(page: VitalsPathwayFollowupRoute.page),
    AutoRoute(page: VitalsPathwayTipsRoute.page),
    AutoRoute(page: VitalsBmiRoute.page),
    AutoRoute(page: VitalsReadingEntryRoute.page),
    AutoRoute(page: VitalsSecondReadingRoute.page),
    AutoRoute(page: VitalsWellbeingRoute.page),
    AutoRoute(page: VitalsResultRoute.page),

    AutoRoute(page: AssessmentCompleteRoute.page),
    AutoRoute(page: AssessmentIntroRoute.page),
    AutoRoute(page: AssessmentSessionRoute.page),
    AutoRoute(page: PricingRoute.page),

    AutoRoute(page: CreateBookingRoute.page),
    AutoRoute(page: ReferralDetailRoute.page),
    AutoRoute(page: AddAppointmentRoute.page),

    AutoRoute(page: VerificationRoute.page),
    AutoRoute(page: SettingsRoute.page),
    AutoRoute(page: ProfileDetailsRoute.page),

    AutoRoute(page: WebViewRoute.page),
  ];
}
