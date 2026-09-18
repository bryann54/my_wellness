// lib/common/widgets/empty_state_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';

class EmptyStateView extends StatelessWidget {
  final String imagePath;
  final IconData floatingIcon;
  final String title;
  final String subtitle;
  final double imageSize;
  final int floatingIconCount;
  final Color? iconColor;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final IconData? buttonIcon;

  const EmptyStateView({
    super.key,
    required this.imagePath,
    required this.floatingIcon,
    required this.title,
    required this.subtitle,
    this.imageSize = 150,
    this.floatingIconCount = 12,
    this.iconColor,
    this.buttonLabel,
    this.onButtonPressed,
    this.buttonIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Floating Icons
          ...List.generate(
            floatingIconCount,
            (index) => _buildFloatingIcon(context, index, isDarkMode),
          ),
          // Foreground Content
          _buildMainContent(context),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon(BuildContext context, int index, bool isDarkMode) {
    final isSmall = index % 2 == 0;
    // Spread icons more naturally across the center
    final xOffset = (index * 35 - (floatingIconCount * 17)).toDouble();
    final startY = index * 25 - 150.0;

    return Positioned(
      left: MediaQuery.of(context).size.width / 2 + xOffset,
      top: MediaQuery.of(context).size.height / 2.5 + startY,
      child: _AnimatedFloatingIcon(
        icon: floatingIcon,
        isSmall: isSmall,
        index: index,
        iconColor: iconColor,
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AnimatedImage(imagePath: imagePath, size: imageSize),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.acme(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.actor(
              fontSize: 15,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
          if (buttonLabel != null && onButtonPressed != null) ...[
            const SizedBox(height: 40),
            AppPrimaryButton(
              onPressed: onButtonPressed,
              label: buttonLabel!,
              icon: buttonIcon,
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 600.ms)
                // Changed 'backOut' to 'Curves.backOut'
                .scale(
                  begin: const Offset(0.9, 0.9),
                  curve: Curves.bounceInOut,
                ),
          ],
        ],
      ),
    );
  }
}

// ── Supporting Animated Widgets ──────────────────────────────────────────────

class _AnimatedFloatingIcon extends StatelessWidget {
  final IconData icon;
  final bool isSmall;
  final int index;
  final Color? iconColor;

  const _AnimatedFloatingIcon({
    required this.icon,
    required this.isSmall,
    required this.index,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = iconColor ?? Theme.of(context).primaryColor;

    return Icon(
      icon,
      color: baseColor.withValues(alpha: 0.1 + (index % 3) * 0.1),
      size: isSmall ? 18.0 : 28.0,
    )
        .animate(onPlay: (controller) => controller.repeat())
        .moveY(
          begin: 0,
          end: -100,
          duration: Duration(seconds: 5 + index % 3),
          curve: Curves.easeInOut,
        )
        .fadeIn(duration: 800.ms)
        .then()
        .fadeOut(delay: Duration(seconds: 3 + index % 2));
  }
}

class _AnimatedImage extends StatelessWidget {
  final String imagePath;
  final double size;

  const _AnimatedImage({required this.imagePath, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: size,
      height: size,
      // Changed 'ContentType.contain' to 'BoxFit.contain'
      fit: BoxFit.contain,
    )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          curve: Curves.elasticOut,
          duration: 1.seconds,
        )
        .shimmer(delay: 2.seconds, duration: 1.5.seconds);
  }
}
