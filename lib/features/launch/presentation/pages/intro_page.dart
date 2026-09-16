import 'package:flutter/material.dart';
import 'package:my_wellness/common/constatnts/routes.dart';
import 'package:my_wellness/common/res/strings.dart';
import 'package:my_wellness/common/widgets/app_button.dart';
import 'package:my_wellness/common/widgets/hero_background.dart';
import 'package:my_wellness/core/injector/injector.dart';
import 'package:my_wellness/core/storage/storage_preference_manager.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final _controller = PageController();
  int _page = 0;

  // Swapped to string constants — no hardcoded copy in the widget tree.
  static const _slides = [
    _IntroSlide(
      image: 'assets/M-PESA.png',
      title: intro_title_1,
      description: intro_body_1,
    ),
    _IntroSlide(
      image: 'assets/M-PESA.png',
      title: intro_title_2,
      description: intro_body_2,
    ),
    _IntroSlide(
      image: 'assets/M-PESA.png',
      title: intro_title_3,
      description: intro_body_3,
    ),
  ];

  bool get _isLastPage => _page == _slides.length - 1;

  Future<void> _finishIntro() async {
    await getIt<SharedPreferencesManager>().putBool(
      SharedPreferencesManager.keyIntroSeen,
      true,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
  }

  void _next() {
    if (_isLastPage) {
      _finishIntro();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _back() => _controller.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeroBackground(
        scrimOpacity: 0.35, // copy-over-photo, needs the dark layer
        child: SafeArea(
          child: Column(
            children: [
              _IntroTopBar(
                showBack: _page > 0,
                onBack: _back,
                onSkip: _isLastPage ? null : _finishIntro,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (index) => setState(() => _page = index),
                  itemBuilder: (context, index) =>
                      _IntroSlideView(slide: _slides[index]),
                ),
              ),
              _PageDots(count: _slides.length, activeIndex: _page),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AppButton(
                  label: _isLastPage ? get_started_button : next_button,
                  onTap: _next,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroTopBar extends StatelessWidget {
  const _IntroTopBar({
    required this.showBack,
    required this.onBack,
    required this.onSkip,
  });

  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: showBack ? onBack : null,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: onSkip,
            child: const Text(skip, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _IntroSlide {
  const _IntroSlide({
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;
}

class _IntroSlideView extends StatelessWidget {
  const _IntroSlideView({required this.slide});

  final _IntroSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: SizedBox(
              width: 160,
              height: 160,
              child: ColoredBox(
                color: theme.colorScheme.primaryContainer,
                child: Image.asset(
                  slide.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_not_supported_outlined,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final active = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == activeIndex ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == activeIndex
                ? active
                : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
