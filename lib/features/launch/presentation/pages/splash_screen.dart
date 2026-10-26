import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/app_lock/presentation/bloc/app_lock_bloc.dart';
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
  bool _lockEvaluated = false;

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

  void _evaluateAppLock() {
    if (_lockEvaluated || !mounted) return;
    _lockEvaluated = true;
    context.read<AppLockBloc>().add(
      AppLockEvaluated(
        reason: AppLocalizations.getString(context, 'appLock.unlockReason'),
      ),
    );
  }

  Future<void> _postAuthNavigation() async {
    if (!mounted) return;
    context.read<AccountBloc>().add(const FetchProfileEvent());
    await _navigateToMain();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LaunchBloc, LaunchState>(
          listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
          listener: (context, state) {
            if (state is LaunchOffline) return;
            if (state is LaunchUnauthenticated) {
              _navigateToAuth();
            } else if (state is LaunchAuthenticated) {
              _evaluateAppLock();
            } else if (state is LaunchError) {
              _navigateToAuth();
            }
          },
        ),
        BlocListener<AppLockBloc, AppLockState>(
          listenWhen: (prev, curr) =>
              prev.phase == AppLockPhase.initial &&
              curr.phase != AppLockPhase.initial,
          listener: (context, _) => _postAuthNavigation(),
        ),
      ],
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splash.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const SplashContent(),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BlocBuilder<LaunchBloc, LaunchState>(
                  buildWhen: (prev, curr) =>
                      (prev is LaunchOffline) != (curr is LaunchOffline),
                  builder: (context, state) {
                    final show = state is LaunchOffline;
                    return AnimatedSlide(
                      duration: AppDurations.medium,
                      curve: Curves.easeOutCubic,
                      offset: show ? Offset.zero : const Offset(0, 1),
                      child: show
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
