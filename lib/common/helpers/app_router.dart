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
        AutoRoute(page: BookingsRoute.page),
        AutoRoute(page: WellnessRoute.page),
        AutoRoute(page: AccountRoute.page),
      ],
    ),

    // Vitals / health
    AutoRoute(page: NotificationsRoute.page),
    AutoRoute(page: SubscriptionsRoute.page),
    AutoRoute(page: MedicationsRoute.page),
    AutoRoute(page: VitalsRoute.page),
    AutoRoute(page: MyHealthRoute.page),
    AutoRoute(page: AppointmentsRoute.page),
    AutoRoute(page: AddMedicationRoute.page),

    // Assessments
    AutoRoute(page: AssessmentCompleteRoute.page),
    AutoRoute(page: AssessmentIntroRoute.page),
    AutoRoute(page: AssessmentSessionRoute.page),
    AutoRoute(page: AssessmentResultRoute.page),

    // Account / auth-adjacent
   
    AutoRoute(page: VerificationRoute.page),
    AutoRoute(page: ConversationalRegisterRoute.page),
    AutoRoute(page: SettingsRoute.page),
    AutoRoute(page: ProfileDetailsRoute.page),

    // Web view
    AutoRoute(page: WebViewRoute.page),
  ];
}
