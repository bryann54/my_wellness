import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_fab.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
import 'package:my_wellness/features/vitals/domain/entities/bs_reading.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/sheets/add_bs_sheet.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/latest_reading_card.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/reading_history_list.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/vitals_empty_state.dart';

class BsTab extends StatelessWidget {
  const BsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VitalsBloc, VitalsState>(
      buildWhen: (p, c) => p.status != c.status || p.bsReadings != c.bsReadings,
      builder: (context, state) {
        if ((state.status == VitalsStatus.initial ||
                state.status == VitalsStatus.loading) &&
            state.bsReadings.isEmpty) {
          return const _BsSkeleton();
        }
        if (state.status == VitalsStatus.error && state.bsReadings.isEmpty) {
          return VitalsEmptyState(
            icon: Icons.wifi_off_outlined,
            title: AppLocalizations.getString(context, 'common.retry'),
            subtitle:
                state.errorMessage ??
                AppLocalizations.getString(context, 'common.error'),
            ctaLabel: AppLocalizations.getString(context, 'common.retry'),
            onCta: () =>
                context.read<VitalsBloc>().add(const LoadVitalsEvent()),
          );
        }
        if (state.bsReadings.isEmpty) {
          return VitalsEmptyState(
            icon: Icons.water_drop_outlined,
            title: AppLocalizations.getString(context, 'vitals.noBsReadings'),
            subtitle: AppLocalizations.getString(
              context,
              'vitals.noBsReadingsSub',
            ),
            ctaLabel: AppLocalizations.getString(context, 'vitals.addReading'),
            onCta: () => AddBsSheet.show(context),
          );
        }

        final latest = state.bsReadings.first;

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: AppFab.compact(
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.getString(context, 'vitals.addReading'),
            onPressed: () => AddBsSheet.show(context),
          ),
          body: RefreshIndicator.adaptive(
            onRefresh: () async {
              context.read<VitalsBloc>().add(const LoadVitalsEvent());
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                112,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LatestReadingCard(
                          kind: ReadingKind.bs,
                          classification: latest.classification,
                          primary: latest.value,
                          unit: latest.unit,
                          timestampIso: latest.takenAt,
                          primaryHeroTag: HeroTags.homeBloodSugarReading,
                          timestampHeroTag: HeroTags.homeBloodSugarTimestamp,
                          secondaryIcon: Icons.restaurant_outlined,
                          secondary: _readingContext(context, latest),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          AppLocalizations.getString(context, 'vitals.history'),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ReadingHistoryList(
                          readings: state.bsReadings
                              .map(
                                (r) => ReadingHistoryRow(
                                  id: r.id,
                                  primary: r.value,
                                  unit: r.unit,
                                  classification: r.classification,
                                  timestampIso: r.takenAt,
                                  secondary: _readingContext(context, r),
                                  onDelete: () => context
                                      .read<VitalsBloc>()
                                      .add(DeleteBsReadingEvent(r.id)),
                                ),
                              )
                              .toList(),
                        ),
                      ],
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

  static String _readingTypeLabel(BuildContext context, String type) {
    return switch (type) {
      'fasting' => AppLocalizations.getString(
        context,
        'vitals.readingTypeFasting',
      ),
      'random' => AppLocalizations.getString(
        context,
        'vitals.readingTypeRandom',
      ),
      'post_meal' => AppLocalizations.getString(
        context,
        'vitals.readingTypePostMeal',
      ),
      _ => type,
    };
  }

  static String _readingContext(BuildContext context, BsReading reading) {
    final timing = switch (reading.mealTiming) {
      'less_than_2h' => AppLocalizations.getString(
        context,
        'vitals.mealTimingLt2h',
      ),
      'more_than_2h' => AppLocalizations.getString(
        context,
        'vitals.mealTimingGt2h',
      ),
      _ => null,
    };
    return [
      _readingTypeLabel(context, reading.readingType),
      ?timing,
    ].join(' · ');
  }
}

class _BsSkeleton extends StatelessWidget {
  const _BsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        112,
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLatestCard(),
                SizedBox(height: AppSpacing.xl),
                ShimmerBox(width: 90, height: 18),
                SizedBox(height: AppSpacing.sm),
                ShimmerListTile(),
                ShimmerListTile(),
                ShimmerListTile(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
