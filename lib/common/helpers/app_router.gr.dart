// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i18;
import 'package:flutter/material.dart' as _i19;
import 'package:my_wellness/common/pages/webview_screen.dart' as _i17;
import 'package:my_wellness/features/account/domain/entities/health_profile.dart'
    as _i20;
import 'package:my_wellness/features/account/presentation/pages/account_screen.dart'
    as _i1;
import 'package:my_wellness/features/account/presentation/pages/edit_profile_screen.dart'
    as _i6;
import 'package:my_wellness/features/assessments/presentation/pages/assessments_screen.dart'
    as _i2;
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart'
    as _i21;
import 'package:my_wellness/features/auth/presentation/pages/auth_screen.dart'
    as _i3;
import 'package:my_wellness/features/auth/presentation/pages/conversational_register_screen.dart'
    as _i5;
import 'package:my_wellness/features/auth/presentation/pages/login_screen.dart'
    as _i9;
import 'package:my_wellness/features/auth/presentation/pages/register_screen.dart'
    as _i12;
import 'package:my_wellness/features/auth/presentation/pages/splash_screen.dart'
    as _i14;
import 'package:my_wellness/features/auth/presentation/pages/verification_screen.dart'
    as _i16;
import 'package:my_wellness/features/bookings/presentation/pages/bookings_screen.dart'
    as _i4;
import 'package:my_wellness/features/geography/presentation/pages/register_stepper_screen.dart'
    as _i13;
import 'package:my_wellness/features/home/presentation/pages/home_screen.dart'
    as _i8;
import 'package:my_wellness/features/notifications/presentation/pages/notifications_screen.dart'
    as _i11;
import 'package:my_wellness/features/subscriptions/presentation/pages/subscriptions_screen.dart'
    as _i15;
import 'package:my_wellness/forgot_password_screen.dart' as _i7;
import 'package:my_wellness/main_screen.dart' as _i10;

/// generated route for
/// [_i1.AccountScreen]
class AccountRoute extends _i18.PageRouteInfo<void> {
  const AccountRoute({List<_i18.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountScreen();
    },
  );
}

/// generated route for
/// [_i2.AssessmentsScreen]
class AssessmentsRoute extends _i18.PageRouteInfo<void> {
  const AssessmentsRoute({List<_i18.PageRouteInfo>? children})
    : super(AssessmentsRoute.name, initialChildren: children);

  static const String name = 'AssessmentsRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i2.AssessmentsScreen();
    },
  );
}

/// generated route for
/// [_i3.AuthScreen]
class AuthRoute extends _i18.PageRouteInfo<void> {
  const AuthRoute({List<_i18.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i3.AuthScreen();
    },
  );
}

/// generated route for
/// [_i4.BookingsScreen]
class BookingsRoute extends _i18.PageRouteInfo<void> {
  const BookingsRoute({List<_i18.PageRouteInfo>? children})
    : super(BookingsRoute.name, initialChildren: children);

  static const String name = 'BookingsRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i4.BookingsScreen();
    },
  );
}

/// generated route for
/// [_i5.ConversationalRegisterScreen]
class ConversationalRegisterRoute extends _i18.PageRouteInfo<void> {
  const ConversationalRegisterRoute({List<_i18.PageRouteInfo>? children})
    : super(ConversationalRegisterRoute.name, initialChildren: children);

  static const String name = 'ConversationalRegisterRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i5.ConversationalRegisterScreen();
    },
  );
}

/// generated route for
/// [_i6.EditProfileScreen]
class EditProfileRoute extends _i18.PageRouteInfo<EditProfileRouteArgs> {
  EditProfileRoute({
    _i19.Key? key,
    required _i20.HealthProfile profile,
    List<_i18.PageRouteInfo>? children,
  }) : super(
         EditProfileRoute.name,
         args: EditProfileRouteArgs(key: key, profile: profile),
         initialChildren: children,
       );

  static const String name = 'EditProfileRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileRouteArgs>();
      return _i6.EditProfileScreen(key: args.key, profile: args.profile);
    },
  );
}

class EditProfileRouteArgs {
  const EditProfileRouteArgs({this.key, required this.profile});

  final _i19.Key? key;

  final _i20.HealthProfile profile;

  @override
  String toString() {
    return 'EditProfileRouteArgs{key: $key, profile: $profile}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditProfileRouteArgs) return false;
    return key == other.key && profile == other.profile;
  }

  @override
  int get hashCode => key.hashCode ^ profile.hashCode;
}

/// generated route for
/// [_i7.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i18.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i18.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i7.ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [_i8.HomeScreen]
class HomeRoute extends _i18.PageRouteInfo<void> {
  const HomeRoute({List<_i18.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i8.HomeScreen();
    },
  );
}

/// generated route for
/// [_i9.LoginScreen]
class LoginRoute extends _i18.PageRouteInfo<void> {
  const LoginRoute({List<_i18.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i9.LoginScreen();
    },
  );
}

/// generated route for
/// [_i10.MainScreen]
class MainRoute extends _i18.PageRouteInfo<void> {
  const MainRoute({List<_i18.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i10.MainScreen();
    },
  );
}

/// generated route for
/// [_i11.NotificationsScreen]
class NotificationsRoute extends _i18.PageRouteInfo<void> {
  const NotificationsRoute({List<_i18.PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i11.NotificationsScreen();
    },
  );
}

/// generated route for
/// [_i12.RegisterScreen]
class RegisterRoute extends _i18.PageRouteInfo<void> {
  const RegisterRoute({List<_i18.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i12.RegisterScreen();
    },
  );
}

/// generated route for
/// [_i13.RegisterStepperScreen]
class RegisterStepperRoute extends _i18.PageRouteInfo<void> {
  const RegisterStepperRoute({List<_i18.PageRouteInfo>? children})
    : super(RegisterStepperRoute.name, initialChildren: children);

  static const String name = 'RegisterStepperRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i13.RegisterStepperScreen();
    },
  );
}

/// generated route for
/// [_i14.SplashScreen]
class SplashRoute extends _i18.PageRouteInfo<void> {
  const SplashRoute({List<_i18.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i14.SplashScreen();
    },
  );
}

/// generated route for
/// [_i15.SubscriptionsScreen]
class SubscriptionsRoute extends _i18.PageRouteInfo<void> {
  const SubscriptionsRoute({List<_i18.PageRouteInfo>? children})
    : super(SubscriptionsRoute.name, initialChildren: children);

  static const String name = 'SubscriptionsRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      return const _i15.SubscriptionsScreen();
    },
  );
}

/// generated route for
/// [_i16.VerificationScreen]
class VerificationRoute extends _i18.PageRouteInfo<VerificationRouteArgs> {
  VerificationRoute({
    _i19.Key? key,
    _i21.SignupPendingEntity? pending,
    List<_i18.PageRouteInfo>? children,
  }) : super(
         VerificationRoute.name,
         args: VerificationRouteArgs(key: key, pending: pending),
         initialChildren: children,
       );

  static const String name = 'VerificationRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VerificationRouteArgs>(
        orElse: () => const VerificationRouteArgs(),
      );
      return _i16.VerificationScreen(key: args.key, pending: args.pending);
    },
  );
}

class VerificationRouteArgs {
  const VerificationRouteArgs({this.key, this.pending});

  final _i19.Key? key;

  final _i21.SignupPendingEntity? pending;

  @override
  String toString() {
    return 'VerificationRouteArgs{key: $key, pending: $pending}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VerificationRouteArgs) return false;
    return key == other.key && pending == other.pending;
  }

  @override
  int get hashCode => key.hashCode ^ pending.hashCode;
}

/// generated route for
/// [_i17.WebViewScreen]
class WebViewRoute extends _i18.PageRouteInfo<WebViewRouteArgs> {
  WebViewRoute({
    _i19.Key? key,
    required String url,
    required String title,
    List<_i18.PageRouteInfo>? children,
  }) : super(
         WebViewRoute.name,
         args: WebViewRouteArgs(key: key, url: url, title: title),
         initialChildren: children,
       );

  static const String name = 'WebViewRoute';

  static _i18.PageInfo page = _i18.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WebViewRouteArgs>();
      return _i17.WebViewScreen(
        key: args.key,
        url: args.url,
        title: args.title,
      );
    },
  );
}

class WebViewRouteArgs {
  const WebViewRouteArgs({this.key, required this.url, required this.title});

  final _i19.Key? key;

  final String url;

  final String title;

  @override
  String toString() {
    return 'WebViewRouteArgs{key: $key, url: $url, title: $title}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WebViewRouteArgs) return false;
    return key == other.key && url == other.url && title == other.title;
  }

  @override
  int get hashCode => key.hashCode ^ url.hashCode ^ title.hashCode;
}
