import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/constatnts/hero.dart';
import 'package:my_wellness/common/constatnts/routes.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/strings.dart';
import 'package:my_wellness/common/widgets/hero_background.dart';
import 'package:my_wellness/core/injector/injector.dart';
import 'package:my_wellness/core/storage/storage_preference_manager.dart';
import 'package:my_wellness/features/launch/presentation/bloc/launch_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _splashHold = Duration(milliseconds: 2500);

  late final bool _introSeen;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _introSeen = getIt<SharedPreferencesManager>().getBool(
          SharedPreferencesManager.keyIntroSeen,
        ) ??
        false;

    if (!_introSeen) {
      _scheduleIntro();
    } else {
      _scheduleLaunchFallback();
    }
  }

  Future<void> _scheduleIntro() async {
    await Future<void>.delayed(_splashHold);
    if (!mounted) return;
    _navigateOnce(AppRoutes.intro);
  }

  Future<void> _scheduleLaunchFallback() async {
    await Future<void>.delayed(_splashHold);
    if (!mounted || _navigated) return;
    _navigateOnce(AppRoutes.signIn);
  }

  void _navigateOnce(String route) {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    if (!_introSeen) {
      return const _SplashBody();
    }

    return BlocProvider(
      create: (_) => getIt<LaunchBloc>()..add(const LaunchStarted()),
      child: BlocListener<LaunchBloc, LaunchState>(
        listener: (context, state) {
          if (state is LaunchUnauthenticated) {
            _scheduleStateNavigation(AppRoutes.signIn);
          }
          if (state is LaunchAuthenticated) {
            _scheduleStateNavigation(AppRoutes.home);
          }
        },
        child: const _SplashBody(),
      ),
    );
  }

  Future<void> _scheduleStateNavigation(String route) async {
    if (_navigated) return;
    await Future<void>.delayed(_splashHold);
    _navigateOnce(route);
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: colorPrimary,
      body: HeroBackground.splash(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: hero_logo,
                  child: Image.asset(
                    'assets/wellness-logo.png',
                    width: 200,
                    height: 200,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.favorite,
                      size: 120,
                      color: colorPrimary,
                    ),
                  ),
                )
                .animate()
                    .fadeIn(duration: 600.ms, curve: Curves.easeOutQuad)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutQuad,
                    ),
                const SizedBox(height: 24),
                const _SplashTagline(text: splash_subtitle).animate(
                  
                ),
                const SizedBox(height: 2),
                const _SplashTagline(text: splash_subtitle_cont),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashTagline extends StatelessWidget {
  const _SplashTagline({required this.text});

  final String text;

  static const _style = TextStyle(
    color: colorPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.1,
  );

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        textAlign: TextAlign.center,
        style: _style,
      );
}
