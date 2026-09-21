import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/get_started_actions.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/on_boarding_view.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/page_indicators.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/onBoarding_data.dart';

class AuthContent extends StatefulWidget {
  const AuthContent({super.key});

  @override
  State<AuthContent> createState() => _AuthContentState();
}

class _AuthContentState extends State<AuthContent> {
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  static const _autoPlayDuration = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(_autoPlayDuration, (_) {
      if (!mounted) return;
      setState(() {
        _currentPage = (_currentPage + 1) % OnboardingData.pages.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final page = OnboardingData.pages[_currentPage];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: OnboardingView(pageData: page, pageIndex: _currentPage),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PageIndicators(current: _currentPage),
                  const SizedBox(height: 20),
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
