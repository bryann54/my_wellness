import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/subscriptions/domain/entities/rc_package_entity.dart';

class SubscriptionPackageTile extends StatelessWidget {
  final RCPackage package;
  final bool isActive;
  final VoidCallback onTap;
  final int index;

  const SubscriptionPackageTile({
    super.key,
    required this.package,
    required this.onTap,
    this.isActive = false,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accent = isActive ? AppColors.success : cs.primary;
    final bg = isActive
        ? (isDark ? const Color(0xFF0D2016) : const Color(0xFFF0FDF4))
        : cs.surfaceContainerLow;

    return Animate(
      delay: Duration(milliseconds: 60 * index),
      effects: [
        FadeEffect(duration: 280.ms),
        SlideEffect(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
          curve: Curves.easeOut,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? accent.withValues(alpha: .5)
                    : cs.outlineVariant.withValues(alpha: 0.3),
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Left: title + type badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                              package.localizedTitle,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            )
                            .animate(delay: 300.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: -1.2, end: 0, curve: Curves.easeOut),
                        const SizedBox(height: 4),
                        _TypeBadge(type: package.packageType, cs: cs)
                            .animate(delay: 300.ms)
                            .fadeIn(duration: 600.ms)
                            .slideX(begin: -1.2, end: 0, curve: Curves.easeOut),
                        const SizedBox(height: 8),
                        Text(
                              package.localizedDescription,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.7),
                              ),
                            )
                            .animate(delay: 300.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 2, end: 0, curve: Curves.easeOut),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right: price + active indicator + subscribe button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                            package.localizedPriceString,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          )
                          .animate(delay: 300.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -1.2, end: 0, curve: Curves.easeOut),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 110,
                        child:
                            ElevatedButton(
                                  onPressed: isActive ? null : onTap,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isActive
                                        ? accent.withValues(alpha: 0.15)
                                        : accent,
                                    foregroundColor: isActive
                                        ? accent
                                        : Colors.white,
                                    textStyle: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: isActive
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              size: 15,
                                              color: accent,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              AppLocalizations.getString(
                                                context,
                                                'subscription.subscribed',
                                              ),
                                              style: TextStyle(color: accent),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          AppLocalizations.getString(
                                            context,
                                            'subscription.subscribe',
                                          ),
                                        ),
                                )
                                .animate(delay: 300.ms)
                                .fadeIn(duration: 600.ms)
                                .slideX(
                                  begin: 2,
                                  end: 0,
                                  curve: Curves.easeOut,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final RCPackageType type;
  final ColorScheme cs;
  const _TypeBadge({required this.type, required this.cs});

  String _getLabel(BuildContext context) => switch (type) {
    RCPackageType.monthly => AppLocalizations.getString(
      context,
      'subscription.monthly',
    ),
    RCPackageType.annual => AppLocalizations.getString(
      context,
      'subscription.yearly',
    ),
    RCPackageType.weekly => AppLocalizations.getString(
      context,
      'subscription.weekly',
    ),
    RCPackageType.lifetime => AppLocalizations.getString(
      context,
      'subscription.lifetime',
    ),
    _ => 'Custom',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getLabel(context).toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.7,
          color: cs.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
