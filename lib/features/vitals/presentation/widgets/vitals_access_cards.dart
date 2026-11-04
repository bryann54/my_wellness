import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/domain/entities/vitals_access.dart';

class VitalsLockedCard extends StatelessWidget {
  final VitalsCaptureKind kind;
  final VoidCallback? onAlertNavigator;

  const VitalsLockedCard({
    super.key,
    required this.kind,
    this.onAlertNavigator,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = kind == VitalsCaptureKind.bp
        ? AppLocalizations.getString(context, 'vitals.bloodPressure')
        : AppLocalizations.getString(context, 'vitals.bloodSugar');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 30,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '$label logging is locked',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Unlock day-to-day blood pressure and blood sugar logging '
                  'with a Monitoring package.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    height: 1.5,
                    color: cs.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton.icon(
                  onPressed: () {
                    context.router.push(
                      PricingRoute(initialServiceId: 'monitor'),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: const Text('Unlock logging'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class VitalsNavigatorCallCard extends StatelessWidget {
  final VitalsAccess access;
  final VoidCallback onAlert;

  const VitalsNavigatorCallCard({
    super.key,
    required this.access,
    required this.onAlert,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final alerted = access.navigatorAlerted;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    alerted
                        ? Icons.check_circle_outline_rounded
                        : Icons.support_agent_rounded,
                    size: 30,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  alerted
                      ? 'A health navigator will call you'
                      : 'Request a health navigator call',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  alerted
                      ? 'We have your request. A navigator will reach out '
                            'shortly to help you get set up.'
                      : 'Logging is restricted on this demo account. '
                            'Request a call and a health navigator will help '
                            'you get access.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    height: 1.5,
                    color: cs.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton.icon(
                  onPressed: alerted ? null : onAlert,
                  icon: Icon(
                    alerted
                        ? Icons.check_rounded
                        : Icons.phone_in_talk_outlined,
                    size: 18,
                  ),
                  label: Text(alerted ? 'Request sent' : 'Request a call'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
