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
         AutoRoute(page: AssessmentsRoute.page),
        AutoRoute(page: BookingsRoute.page),
        AutoRoute(page: AccountRoute.page),

      ],
    ),
    AutoRoute(page: NotificationsRoute.page),
    AutoRoute(page: SubscriptionsRoute.page),

    AutoRoute(page: WebViewRoute.page),

    AutoRoute(page: EditProfileRoute.page),
    AutoRoute(page: VerificationRoute.page),
   
    AutoRoute(page: ConversationalRegisterRoute.page),
  ];
}
