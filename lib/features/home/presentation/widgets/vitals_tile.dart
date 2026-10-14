import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';

enum VitalsTileKind { bp, bs }

class VitalsTile extends StatelessWidget {
  const VitalsTile({super.key, required this.kind});

  final VitalsTileKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isBp = kind == VitalsTileKind.bp;
    final accent = isBp
        ? (isDark ? AppColors.vitalBpDark : AppColors.vitalBp)
        : (isDark ? AppColors.vitalBsDark : AppColors.vitalBs);

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
        final dateTimeParts = reading == null
            ? const <String>[]
            : friendlyDateTime(takenAt!).split(' · ');
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
        final radius = AppRadius.mdAll;

        return Material(
          color: colors.surfaceContainerLow,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: isLoading
                ? null
                : hasError
                ? () => context.read<VitalsBloc>().add(const LoadVitalsEvent())
                : () => context.router.push(route),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: AppRadius.smAll,
                        ),
                        child: Icon(
                          isBp
                              ? Icons.favorite_outline
                              : Icons.water_drop_outlined,
                          color: accent,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (reading != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              isBp
                                  ? '${state.latestBp!.systolic}/${state.latestBp!.diastolic}'
                                  : state.latestBs!.value,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          isBp ? 'mmHg' : state.latestBs!.unit,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateTimeParts.first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        if (dateTimeParts.length > 1)
                          Text(
                            dateTimeParts[1],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ] else
                    Row(
                      children: [
                        if (isLoading) ...[
                          SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Expanded(
                          child: Text(
                            AppLocalizations.getString(
                              context,
                              isLoading
                                  ? 'common.loading'
                                  : hasError
                                  ? 'homeDashboard.readingsUnavailable'
                                  : 'homeDashboard.noReadingRecorded',
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (!isLoading) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          hasError
                              ? Icons.refresh_rounded
                              : reading == null
                              ? Icons.add_rounded
                              : Icons.history_rounded,
                          size: 16,
                          color: colors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            AppLocalizations.getString(
                              context,
                              hasError
                                  ? 'common.retry'
                                  : reading == null
                                  ? 'vitals.addReading'
                                  : 'homeDashboard.viewHistory',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
