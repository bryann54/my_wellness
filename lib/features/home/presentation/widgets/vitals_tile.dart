import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/features/home/presentation/widgets/vitals_status_pill.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';

enum VitalsTileKind { bp, bs }

class VitalsTile extends StatelessWidget {
  const VitalsTile({super.key, required this.kind});

  final VitalsTileKind kind;

  static (Color, Color) _accentFor(bool isBp, bool isDark) => isBp
      ? (
          const Color(0xFF3B82F6),
          isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
        )
      : (
          const Color(0xFFDC2626),
          isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isBp = kind == VitalsTileKind.bp;
    final (accent, accentText) = _accentFor(isBp, isDark);

    return BlocBuilder<VitalsBloc, VitalsState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.bpReadings != current.bpReadings ||
          previous.bsReadings != current.bsReadings,
      builder: (context, state) {
        final reading = isBp ? state.latestBp : state.latestBs;
        final takenAt = isBp
            ? state.latestBp?.takenAt
            : state.latestBs?.takenAt;
        final isLoading =
            reading == null &&
            (state.status == VitalsStatus.initial ||
                state.status == VitalsStatus.loading);
        final hasError = reading == null && state.status == VitalsStatus.error;
        final title = AppLocalizations.getString(
          context,
          isBp ? 'vitals.bloodPressure' : 'vitals.bloodSugar',
        );
        final route = VitalsRoute(initialTab: isBp ? 0 : 1);

        final classification = isBp
            ? state.latestBp?.classification
            : state.latestBs?.classification;
        final titleHeroTag = isBp
            ? HeroTags.homeBloodPressure
            : HeroTags.homeBloodSugar;
        final readingHeroTag = isBp
            ? HeroTags.homeBloodPressureReading
            : HeroTags.homeBloodSugarReading;
        final timestampHeroTag = isBp
            ? HeroTags.homeBloodPressureTimestamp
            : HeroTags.homeBloodSugarTimestamp;

        return Material(
          color: Color.alphaBlend(
            accent.withValues(alpha: isDark ? 0.16 : 0.08),
            colors.surfaceContainerLow,
          ),
          borderRadius: AppRadius.mdAll,
          child: InkWell(
            borderRadius: AppRadius.mdAll,
            onTap: isLoading
                ? null
                : hasError
                ? () => context.read<VitalsBloc>().add(const LoadVitalsEvent())
                : () => context.router.push(route),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isBp
                              ? Icons.monitor_heart_rounded
                              : Icons.water_drop_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: _hero(
                            titleHeroTag,
                            Text(
                              title,
                              maxLines: 1,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: accentText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (reading != null) ...[
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: _hero(
                        readingHeroTag,
                        Text.rich(
                          TextSpan(
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                              letterSpacing: -0.5,
                              color: colors.onSurface,
                            ),
                            children: [
                              if (isBp) ...[
                                TextSpan(text: '${state.latestBp!.systolic}'),
                                TextSpan(
                                  text: '/',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                TextSpan(text: '${state.latestBp!.diastolic}'),
                              ] else
                                TextSpan(
                                  text: _trimDecimal(state.latestBs!.value),
                                ),
                              TextSpan(
                                text:
                                    ' ${isBp ? 'mmHg' : state.latestBs!.unit}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontSize: 12,
                                  height: 1.0,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w500,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    VitalsStatusPill(
                      classification: classification,
                      compact: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _hero(
                      timestampHeroTag,
                      Text(
                        friendlyDateTime(takenAt!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ] else
                    _EmptyState(
                      isLoading: isLoading,
                      hasError: hasError,
                      accent: accentText,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _trimDecimal(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return value;
    return parsed == parsed.roundToDouble()
        ? parsed.toStringAsFixed(0)
        : parsed.toStringAsFixed(1);
  }

  Widget _hero(String tag, Widget child) => Hero(
    tag: tag,
    flightShuttleBuilder: (_, _, _, _, toHero) =>
        (toHero.widget as Hero).child,
    child: Material(color: Colors.transparent, child: child),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isLoading,
    required this.hasError,
    required this.accent,
  });

  final bool isLoading;
  final bool hasError;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (isLoading) {
      return Row(
        children: [
          SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: accent),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            AppLocalizations.getString(context, 'common.loading'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.getString(
            context,
            hasError
                ? 'homeDashboard.readingsUnavailable'
                : 'homeDashboard.noReadingRecorded',
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(
              hasError ? Icons.refresh_rounded : Icons.add_rounded,
              size: 16,
              color: accent,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              AppLocalizations.getString(
                context,
                hasError ? 'common.retry' : 'vitals.addReading',
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
