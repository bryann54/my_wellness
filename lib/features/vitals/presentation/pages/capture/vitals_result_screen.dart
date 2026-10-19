import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_capture_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/utils/classification_colors.dart';

@RoutePage()
class VitalsResultScreen extends StatelessWidget {
  final VitalsCaptureKind kind;
  const VitalsResultScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<VitalsCaptureBloc>(),
      child: _Body(kind: kind),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.kind});

  final VitalsCaptureKind kind;

  void _returnToVitals(BuildContext context) {
    context.read<VitalsCaptureBloc>().add(const CancelVitalsCaptureEvent());
    context.router.popUntilRouteWithName(VitalsRoute.name);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VitalsCaptureBloc>().state;
    final result = state.result;
    final referral = state.referral;
    final cs = Theme.of(context).colorScheme;

    if (result == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    // Refresh the main vitals bloc so the tab shows the new reading.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VitalsBloc>().add(const LoadVitalsEvent());
    });

    // BS returns its classification on the reading itself; BP exposes it
    // at the session level.
    final classification = kind == VitalsCaptureKind.bp
        ? result.bpCategory
        : (result.firstReading?.classification ?? 'neutral');
    final label = kind == VitalsCaptureKind.bp
        ? result.bpCategoryLabel
        : (result.firstReading?.classificationLabel ?? '');
    final accent = classificationColor(classification);
    final facility = referral?.recommendedFacility;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          CustomAppBar(
            title: AppLocalizations.getString(context, 'vitals.title'),
            isHome: false,
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded, size: 16, color: accent),
                ),
                const SizedBox(width: 10),
                Text(
                  'Reading saved',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label.isNotEmpty)
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  if (result.finalRecommendation.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      result.finalRecommendation,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.5,
                        color: cs.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (facility != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Recommended care',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    if (facility.locality.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        facility.locality,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                    if (referral?.reason != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        referral!.reason!,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: cs.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            OutlinedButton.icon(
              onPressed: () {
                context.read<VitalsCaptureBloc>().add(
                  const CancelVitalsCaptureEvent(),
                );
                context.router.popUntilRouteWithName(VitalsRoute.name);
                context.read<VitalsCaptureBloc>().add(
                  StartVitalsCaptureEvent(kind),
                );
                context.router.push(VitalsCaptureIntroRoute(kind: kind));
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Log another reading'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: cs.onSurface,
                side: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              onPressed: () => _returnToVitals(context),
              label: 'Back to vitals',
            ),
          ],
        ),
      ),
    );
  }
}
