// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:auto_route/auto_route.dart' as _i15;
import 'package:flutter/material.dart' as _i16;
import 'package:my_wellness/common/pages/webview_screen.dart' as _i14;
import 'package:my_wellness/features/account/domain/entities/health_profile.dart'
    as _i17;
import 'package:my_wellness/features/account/presentation/pages/account_screen.dart'
    as _i1;
import 'package:my_wellness/features/account/presentation/pages/edit_profile_screen.dart'
    as _i4;
import 'package:my_wellness/features/auth/domain/entities/signup_pending_entity.dart'
    as _i18;
import 'package:my_wellness/features/auth/presentation/pages/auth_screen.dart'
    as _i2;
import 'package:my_wellness/features/auth/presentation/pages/conversational_register_screen.dart'
    as _i3;
import 'package:my_wellness/features/auth/presentation/pages/login_screen.dart'
    as _i7;
import 'package:my_wellness/features/auth/presentation/pages/register_screen.dart'
    as _i10;
import 'package:my_wellness/features/auth/presentation/pages/splash_screen.dart'
    as _i11;
import 'package:my_wellness/features/auth/presentation/pages/verification_screen.dart'
    as _i13;
import 'package:my_wellness/features/home/presentation/pages/home_screen.dart'
    as _i6;
import 'package:my_wellness/features/notifications/presentation/pages/notifications_screen.dart'
    as _i9;
import 'package:my_wellness/features/subscriptions/presentation/pages/subscriptions_screen.dart'
    as _i12;
import 'package:my_wellness/forgot_password_screen.dart' as _i5;
import 'package:my_wellness/main_screen.dart' as _i8;

/// generated route for
/// [_i1.AccountScreen]
class AccountRoute extends _i15.PageRouteInfo<void> {
  const AccountRoute({List<_i15.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountScreen();
    },
  );
}

/// generated route for
/// [_i2.AuthScreen]
class AuthRoute extends _i15.PageRouteInfo<void> {
  const AuthRoute({List<_i15.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i2.AuthScreen();
    },
  );
}

/// generated route for
/// [_i3.ConversationalRegisterScreen]
class ConversationalRegisterRoute extends _i15.PageRouteInfo<void> {
  const ConversationalRegisterRoute({List<_i15.PageRouteInfo>? children})
    : super(ConversationalRegisterRoute.name, initialChildren: children);

  static const String name = 'ConversationalRegisterRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i3.ConversationalRegisterScreen();
    },
  );
}

/// generated route for
/// [_i4.EditProfileScreen]
class EditProfileRoute extends _i15.PageRouteInfo<EditProfileRouteArgs> {
  EditProfileRoute({
    _i16.Key? key,
    required _i17.HealthProfile profile,
    List<_i15.PageRouteInfo>? children,
  }) : super(
         EditProfileRoute.name,
         args: EditProfileRouteArgs(key: key, profile: profile),
         initialChildren: children,
       );

  static const String name = 'EditProfileRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileRouteArgs>();
      return _i4.EditProfileScreen(key: args.key, profile: args.profile);
    },
  );
}

class EditProfileRouteArgs {
  const EditProfileRouteArgs({this.key, required this.profile});

  final _i16.Key? key;

  final _i17.HealthProfile profile;

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
/// [_i5.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i15.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i15.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i5.ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [_i6.HomeScreen]
class HomeRoute extends _i15.PageRouteInfo<void> {
  const HomeRoute({List<_i15.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i6.HomeScreen();
    },
  );
}

/// generated route for
/// [_i7.LoginScreen]
class LoginRoute extends _i15.PageRouteInfo<void> {
  const LoginRoute({List<_i15.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i7.LoginScreen();
    },
  );
}

/// generated route for
/// [_i8.MainScreen]
class MainRoute extends _i15.PageRouteInfo<void> {
  const MainRoute({List<_i15.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i8.MainScreen();
    },
  );
}

/// generated route for
/// [_i9.NotificationsScreen]
class NotificationsRoute extends _i15.PageRouteInfo<void> {
  const NotificationsRoute({List<_i15.PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i9.NotificationsScreen();
    },
  );
}

/// generated route for
/// [_i10.RegisterScreen]
class RegisterRoute extends _i15.PageRouteInfo<void> {
  const RegisterRoute({List<_i15.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i10.RegisterScreen();
    },
  );
}

/// generated route for
/// [_i11.SplashScreen]
class SplashRoute extends _i15.PageRouteInfo<void> {
  const SplashRoute({List<_i15.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i11.SplashScreen();
    },
  );
}

/// generated route for
/// [_i12.SubscriptionsScreen]
class SubscriptionsRoute extends _i15.PageRouteInfo<void> {
  const SubscriptionsRoute({List<_i15.PageRouteInfo>? children})
    : super(SubscriptionsRoute.name, initialChildren: children);

  static const String name = 'SubscriptionsRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i12.SubscriptionsScreen();
    },
  );
}

/// generated route for
/// [_i13.VerificationScreen]
class VerificationRoute extends _i15.PageRouteInfo<VerificationRouteArgs> {
  VerificationRoute({
    _i16.Key? key,
    _i18.SignupPendingEntity? pending,
    List<_i15.PageRouteInfo>? children,
  }) : super(
         VerificationRoute.name,
         args: VerificationRouteArgs(key: key, pending: pending),
         initialChildren: children,
       );

  static const String name = 'VerificationRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VerificationRouteArgs>(
        orElse: () => const VerificationRouteArgs(),
      );
      return _i13.VerificationScreen(key: args.key, pending: args.pending);
    },
  );
}

class VerificationRouteArgs {
  const VerificationRouteArgs({this.key, this.pending});

  final _i16.Key? key;

  final _i18.SignupPendingEntity? pending;

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
/// [_i14.WebViewScreen]
class WebViewRoute extends _i15.PageRouteInfo<WebViewRouteArgs> {
  WebViewRoute({
    _i16.Key? key,
    required String url,
    required String title,
    List<_i15.PageRouteInfo>? children,
  }) : super(
         WebViewRoute.name,
         args: WebViewRouteArgs(key: key, url: url, title: title),
         initialChildren: children,
       );

  static const String name = 'WebViewRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WebViewRouteArgs>();
      return _i14.WebViewScreen(
        key: args.key,
        url: args.url,
        title: args.title,
      );
    },
  );
}

class WebViewRouteArgs {
  const WebViewRouteArgs({this.key, required this.url, required this.title});

  final _i16.Key? key;

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
