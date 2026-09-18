import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/functions.dart';

class EntitlementTile extends StatelessWidget {
  final entitlement;
  final int index;
  const EntitlementTile({
    super.key,
    required this.entitlement,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const accent = AppColors.success;
    final expiry = entitlement.expirationDate;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.25), width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                size: 18,
                color: accent,
              ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 800.ms)
                .slideX(begin: -1.2, end: 0, curve: Curves.easeOut),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entitlement.identifier.toUpperCase(),
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: cs.onSurface,
                    ),
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -2, end: 0, curve: Curves.easeOut),
                  if (expiry != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      '${AppLocalizations.getString(context, 'subscription.expiresOn')} ${fmtDate(expiry)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.45),
                      ),
                    )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 2, end: 0, curve: Curves.easeOut),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppLocalizations.getString(
                  context,
                  'subscription.active',
                ).toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: accent,
                ),
              ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 400.ms)
                .slideX(begin: 1.2, end: 0, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}
