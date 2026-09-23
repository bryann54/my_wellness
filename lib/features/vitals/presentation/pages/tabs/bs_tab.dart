import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_fab.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
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
        if (state.status == VitalsStatus.loading && state.bsReadings.isEmpty) {
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                LatestReadingCard(
                  kind: ReadingKind.bs,
                  classification: state.bsReadings.first.classification,
                  primary: state.bsReadings.first.value,
                  unit: state.bsReadings.first.unit,
                  timestampIso: state.bsReadings.first.takenAt,
                  secondary: _readingTypeLabel(
                    context,
                    state.bsReadings.first.readingType,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.getString(context, 'vitals.history'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ReadingHistoryList(
                  readings: state.bsReadings
                      .map(
                        (r) => ReadingHistoryRow(
                          id: r.id,
                          primary: r.value,
                          unit: r.unit,
                          classification: r.classification,
                          timestampIso: r.takenAt,
                          onDelete: () => context.read<VitalsBloc>().add(
                            DeleteBsReadingEvent(r.id),
                          ),
                        ),
                      )
                      .toList(),
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
      'fasting' => AppLocalizations.getString(context, 'vitals.fasting'),
      'random' => AppLocalizations.getString(context, 'vitals.random'),
      'post_meal' => AppLocalizations.getString(context, 'vitals.postMeal'),
      _ => type,
    };
  }
}

class _BsSkeleton extends StatelessWidget {
  const _BsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: const [
        ShimmerLatestCard(),
        SizedBox(height: 24),
        ShimmerBox(width: 90, height: 18),
        SizedBox(height: 12),
        ShimmerListTile(),
        ShimmerListTile(),
        ShimmerListTile(),
      ],
    );
  }
}
