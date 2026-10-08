import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_wellness/common/constants/hero.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/get_started_actions.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/on_boarding_view.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/onBoarding_data.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/page_indicators.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/language_selector.dart';
class AuthContent extends StatefulWidget {
  const AuthContent({super.key});

  @override
  State<AuthContent> createState() => _AuthContentState();
}

class _AuthContentState extends State<AuthContent> with WidgetsBindingObserver {
  static const _autoAdvanceInterval = Duration(seconds: 6);

  Timer? _timer;

  int _currentPage = 0;
  bool _isForeground = true;

  int get _pageCount => OnboardingData.pages.length;
  bool get _isLastPage => _currentPage >= _pageCount - 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasForeground = _isForeground;
    _isForeground = state == AppLifecycleState.resumed;
    if (wasForeground != _isForeground) {
      _syncTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
  void _syncTimer() {
    final reducedMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final shouldRun = !_isLastPage && _isForeground && !reducedMotion;

    if (shouldRun && _timer == null) {
      _startTimer();
    } else if (!shouldRun && _timer != null) {
      _stopTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(_autoAdvanceInterval, (_) {
      if (!mounted) return;
      if (_isLastPage) {
        _stopTimer();
        return;
      }
      setState(() => _currentPage += 1);
      _syncTimer();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    final page = OnboardingData.pages[_currentPage];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: Row(children: [
                Hero(
                  tag: HeroTags.authLogo,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                const LanguageSelector()
              ]),
            ),

            Expanded(
              child: OnboardingView(pageData: page, pageIndex: _currentPage),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PageIndicators(current: _currentPage),
                  const SizedBox(height: AppSpacing.lg),
                  const GetStartedActions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
