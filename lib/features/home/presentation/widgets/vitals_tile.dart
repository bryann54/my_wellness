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
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isBp = kind == VitalsTileKind.bp;

    final accent = isBp
        ? (isDark ? AppColors.vitalBpDark : AppColors.vitalBp)
        : (isDark ? AppColors.vitalBsDark : AppColors.vitalBs);
    final surface = isBp
        ? (isDark ? AppColors.vitalBpSurfaceDark : AppColors.vitalBpSurface)
        : (isDark ? AppColors.vitalBsSurfaceDark : AppColors.vitalBsSurface);

    return BlocBuilder<VitalsBloc, VitalsState>(
      buildWhen: (p, c) =>
          p.bpReadings != c.bpReadings || p.bsReadings != c.bsReadings,
      builder: (context, state) {
        final reading = isBp ? state.latestBp : state.latestBs;
        final takenAt = isBp
            ? state.latestBp?.takenAt
            : state.latestBs?.takenAt;

        return InkWell(
          onTap: () =>
              context.router.push(VitalsRoute(initialTab: isBp ? 0 : 1)),
          borderRadius: AppRadius.lgAll,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: accent.withValues(alpha: 0.22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Icon(
                        isBp
                            ? Icons.favorite_outline
                            : Icons.water_drop_outlined,
                        color: accent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        AppLocalizations.getString(
                          context,
                          isBp ? 'vitals.bloodPressure' : 'vitals.bloodSugar',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                if (reading == null)
                  Text(
                    AppLocalizations.getString(
                      context,
                      'vitals.logFirstReading',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.72),
                    ),
                  )
                else
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
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        isBp ? 'mmHg' : state.latestBs!.unit,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: AppSpacing.sm),
                Text(
                  reading == null
                      ? AppLocalizations.getString(
                          context,
                          'vitals.startTracking',
                        )
                      : friendlyDateTime(takenAt!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
