import 'package:flutter/material.dart';
import 'package:my_wellness/features/appointments/presentation/pages/appointments_page.dart';
import 'package:my_wellness/features/assessments/presentation/pages/assessments_page.dart';
import 'package:my_wellness/features/auth/presentation/pages/register_page.dart';
import 'package:my_wellness/features/auth/presentation/pages/sign_in_page.dart';
import 'package:my_wellness/features/care_navigation/presentation/pages/care_navigation_page.dart';
import 'package:my_wellness/features/care_plan/presentation/pages/care_plan_page.dart';
import 'package:my_wellness/features/home/presentation/pages/home_page.dart';
import 'package:my_wellness/features/launch/presentation/pages/intro_page.dart';
import 'package:my_wellness/features/launch/presentation/pages/splash_page.dart';
import 'package:my_wellness/features/onboarding_consent/presentation/pages/consent_page.dart';
import 'package:my_wellness/features/profile/presentation/pages/profile_page.dart';
import 'package:my_wellness/features/resources/presentation/pages/resources_page.dart';
import 'package:my_wellness/features/results/presentation/pages/results_page.dart';
import 'package:my_wellness/features/vitals/presentation/pages/vitals_page.dart';

abstract final class AppRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static const launch = '/';
  static const intro = '/intro';
  static const signIn = '/sign-in';
  static const register = '/register';
  static const home = '/home';
  static const consent = '/consent';
  static const assessments = '/assessments';
  static const carePlan = '/care-plan';
  static const results = '/results';
  static const appointments = '/appointments';
  static const careNavigation = '/care-navigation';
  static const vitals = '/vitals';
  static const resources = '/resources';
  static const profile = '/profile';
  static Route<void> generateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      launch => const SplashPage(),
      intro => const IntroPage(),
      signIn => const SignInPage(),
      register => const RegisterPage(),
      home => const HomePage(),
      consent => const ConsentPage(),
      assessments => const AssessmentsPage(),
      carePlan => const CarePlanPage(),
      results => const ResultsPage(),
      appointments => const AppointmentsPage(),
      careNavigation => const CareNavigationPage(),
      vitals => const VitalsPage(),
      resources => const ResourcesPage(),
      profile => const ProfilePage(),
      _ => const SplashPage(),
    };
    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }
}
