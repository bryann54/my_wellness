import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
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

        return InkWell(
          onTap: () =>
              context.router.push(VitalsRoute(initialTab: isBp ? 0 : 1)),
          borderRadius: AppRadius.lgAll,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: AppRadius.lgAll,
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
                        color: accent,
                        borderRadius: AppRadius.mdAll,
                      ),
                      child: Icon(
                        isBp ? Icons.favorite : Icons.water_drop,
                        color: AppColors.background,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.getString(
                              context,
                              isBp
                                  ? 'vitals.bloodPressure'
                                  : 'vitals.bloodSugar',
                            ),
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            AppLocalizations.getString(
                              context,
                              isBp ? 'vitals.bpSubtitle' : 'vitals.bsSubtitle',
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
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
                    style: theme.textTheme.titleMedium,
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        isBp
                            ? '${state.latestBp!.systolic}/${state.latestBp!.diastolic}'
                            : state.latestBs!.value,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
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
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Text(
                    AppLocalizations.getString(context, 'vitals.startTracking'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
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
