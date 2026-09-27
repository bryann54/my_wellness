import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/core/services/pin_service.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/bloc/biometrics/biometrics_bloc.dart';
import 'package:my_wellness/features/auth/presentation/widgets/security_setup_sheet.dart';
import 'package:my_wellness/features/auth/presentation/widgets/splash/splash_failure_sheet.dart';
import 'package:my_wellness/features/auth/presentation/widgets/splash/splash_offline_banner.dart';
import 'package:my_wellness/features/auth/presentation/widgets/splash_content.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minimumDisplay = Duration(milliseconds: 1400);

  final _startedAt = DateTime.now();
  bool _navigated = false;
  bool _biometricsDispatched = false;
  bool _sheetOpen = false;
  bool _offlineAcknowledged = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
    context.read<AuthBloc>().add(const CheckConnectivityEvent());
  }

  Future<void> _waitForMinimum() async {
    final elapsed = DateTime.now().difference(_startedAt);
    if (elapsed < _minimumDisplay) {
      await Future.delayed(_minimumDisplay - elapsed);
    }
  }

  Future<void> _navigateTo(String route) async {
    if (_navigated || !mounted) return;
    _navigated = true;
    await _waitForMinimum();
    if (!mounted) return;
    context.router.replace(
      route == 'auth' ? const AuthRoute() : const MainRoute(),
    );
  }

  Future<void> _dispatchBiometrics() async {
    if (_biometricsDispatched || !mounted) return;
    _biometricsDispatched = true;

    final hasPin = await PinService().hasPin();
    if (!mounted) return;

    if (hasPin) {
      context.read<BiometricsBloc>().add(CheckBiometrics());
    } else {
      await SecuritySetupSheet.show(context);
      if (!mounted) return;
      await _navigateTo('main');
    }
  }

  Future<void> _postAuthNavigation() async {
    if (!mounted) return;
    context.read<AccountBloc>().add(const FetchProfileEvent());
    await _navigateTo('main');
  }

  /// Called when the user dismisses the offline banner. Only then do we
  /// proceed to biometrics.
Future<void> _onOfflineAcknowledged() async {
    if (_offlineAcknowledged) return;
    setState(() => _offlineAcknowledged = true);

    final auth = context.read<AuthBloc>().state;
    if (auth.status == AuthStatus.authenticated) {
      await _dispatchBiometrics();
    } else {
      await _navigateTo('auth');
    }
  }

  Future<void> _showFailureSheet() async {
    if (_sheetOpen || !mounted) return;
    _sheetOpen = true;

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<BiometricsBloc>(),
        child: const SplashFailureSheet(),
      ),
    );

    _sheetOpen = false;

    if (!mounted) return;
    if (context.read<BiometricsBloc>().state.isAuthenticated) {
      await _postAuthNavigation();
    }
  }

  String _statusLabel(AuthState state) {
    if (state.status == AuthStatus.loading) {
      return AppLocalizations.getString(context, 'splash.checkingSession');
    }
    if (state.status == AuthStatus.authenticated) {
      return AppLocalizations.getString(context, 'splash.loadingProfile');
    }
    return AppLocalizations.getString(context, 'splash.ready');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (_, state) {
            if (state.status == AuthStatus.unauthenticated ||
                state.status == AuthStatus.error) {
              _navigateTo('auth');
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              (prev is AuthOffline) != (curr is AuthOffline),
          listener: (context, state) {
            // Online and authenticated: proceed to biometrics immediately.
            if (state is! AuthOffline &&
                state.status == AuthStatus.authenticated &&
                !_offlineAcknowledged) {
              _dispatchBiometrics();
            }
          },
        ),
        BlocListener<BiometricsBloc, BiometricsState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status ||
              prev.isAuthenticated != curr.isAuthenticated,
          listener: (context, state) {
            if (state.status == BiometricsStatus.pinFallback ||
                state.status == BiometricsStatus.error) {
              _showFailureSheet();
            } else if (state.isAuthenticated && !_sheetOpen) {
              _postAuthNavigation();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackgroundColor
            : AppColors.lightBackgroundColor,
        body: SafeArea(
          top: false,
          child: BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (prev, curr) =>
                prev.status != curr.status || (curr is AuthOffline),
            builder: (context, state) {
              final showBanner = state is AuthOffline && !_offlineAcknowledged;

              return Column(
                children: [
                  Expanded(
                    child: SplashContent(statusLabel: _statusLabel(state)),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: showBanner
                        ? SplashOfflineBanner(
                            onContinue: _onOfflineAcknowledged,
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
