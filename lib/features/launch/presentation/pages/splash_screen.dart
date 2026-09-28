import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/core/services/pin_service.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/biometrics/biometrics_bloc.dart';
import 'package:my_wellness/features/auth/presentation/widgets/security_setup_sheet.dart';
import 'package:my_wellness/features/auth/presentation/widgets/splash/splash_failure_sheet.dart';
import 'package:my_wellness/features/auth/presentation/widgets/splash/splash_offline_banner.dart';
import 'package:my_wellness/features/auth/presentation/widgets/splash_content.dart';
import 'package:my_wellness/features/launch/presentation/bloc/launch_bloc.dart';
import 'package:my_wellness/features/launch/presentation/bloc/launch_event.dart';
import 'package:my_wellness/features/launch/presentation/bloc/launch_state.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<LaunchBloc>().add(const StartLaunchEvent());
  }

  Future<void> _waitForMinimum() async {
    final elapsed = DateTime.now().difference(_startedAt);
    if (elapsed < _minimumDisplay) {
      await Future.delayed(_minimumDisplay - elapsed);
    }
  }

  Future<void> _navigateToAuth() async {
    if (_navigated || !mounted) return;
    _navigated = true;
    await _waitForMinimum();
    if (!mounted) return;
    context.router.replace(const AuthRoute());
  }

  Future<void> _navigateToMain() async {
    if (_navigated || !mounted) return;
    _navigated = true;
    await _waitForMinimum();
    if (!mounted) return;
    context.router.replace(const MainRoute());
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
      await _postAuthNavigation();
    }
  }

  Future<void> _postAuthNavigation() async {
    if (!mounted) return;
    context.read<AccountBloc>().add(const FetchProfileEvent());
    await _navigateToMain();
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

  String _statusLabel(LaunchState state) {
    if (state is LaunchLoading) {
      return AppLocalizations.getString(context, 'splash.checkingSession');
    }
    if (state is LaunchAuthenticated) {
      return AppLocalizations.getString(context, 'splash.loadingProfile');
    }
    return AppLocalizations.getString(context, 'splash.ready');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocListener(
      listeners: [
        BlocListener<LaunchBloc, LaunchState>(
          listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
          listener: (context, state) {
            if (state is LaunchOffline) return;
            if (state is LaunchUnauthenticated) {
              _navigateToAuth();
            } else if (state is LaunchAuthenticated) {
              _dispatchBiometrics();
            } else if (state is LaunchError) {
              _navigateToAuth();
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
        body: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splash.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: BlocBuilder<LaunchBloc, LaunchState>(
                  buildWhen: (prev, curr) =>
                      prev.runtimeType != curr.runtimeType,
                  builder: (context, state) {
                    return SplashContent(statusLabel: _statusLabel(state));
                  },
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BlocBuilder<LaunchBloc, LaunchState>(
                  buildWhen: (prev, curr) =>
                      (prev is LaunchOffline) != (curr is LaunchOffline),
                  builder: (context, state) {
                    final showBanner = state is LaunchOffline;
                    return AnimatedSlide(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      offset: showBanner ? Offset.zero : const Offset(0, 1),
                      child: showBanner
                          ? SplashOfflineBanner(
                              onContinue: () => context.read<LaunchBloc>().add(
                                const ContinueOfflineEvent(),
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
