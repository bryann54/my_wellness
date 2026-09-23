import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_fab.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/sheets/add_bp_sheet.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/latest_reading_card.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/reading_history_list.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/vitals_empty_state.dart';

class BpTab extends StatelessWidget {
  const BpTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VitalsBloc, VitalsState>(
      buildWhen: (p, c) => p.status != c.status || p.bpReadings != c.bpReadings,
      builder: (context, state) {
        if (state.status == VitalsStatus.loading && state.bpReadings.isEmpty) {
          return const _BpSkeleton();
        }
        if (state.status == VitalsStatus.error && state.bpReadings.isEmpty) {
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
        if (state.bpReadings.isEmpty) {
          return VitalsEmptyState(
            icon: Icons.favorite_outline,
            title: AppLocalizations.getString(context, 'vitals.noBpReadings'),
            subtitle: AppLocalizations.getString(
              context,
              'vitals.noBpReadingsSub',
            ),
            ctaLabel: AppLocalizations.getString(context, 'vitals.addReading'),
            onCta: () => AddBpSheet.show(context),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: AppFab.compact(
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.getString(context, 'vitals.addReading'),
            onPressed: () => AddBpSheet.show(context),
          ),
          body: RefreshIndicator.adaptive(
            onRefresh: () async =>
                context.read<VitalsBloc>().add(const LoadVitalsEvent()),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                LatestReadingCard(
                  kind: ReadingKind.bp,
                  classification: state.bpReadings.first.classification,
                  primary:
                      '${state.bpReadings.first.systolic}/${state.bpReadings.first.diastolic}',
                  unit: 'mmHg',
                  timestampIso: state.bpReadings.first.takenAt,
                  secondary: state.bpReadings.first.pulse == null
                      ? null
                      : '${AppLocalizations.getString(context, 'vitals.pulse')}: '
                            '${state.bpReadings.first.pulse}',
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.getString(context, 'vitals.history'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ReadingHistoryList(
                  readings: state.bpReadings
                      .map(
                        (r) => ReadingHistoryRow(
                          id: r.id,
                          primary: '${r.systolic}/${r.diastolic}',
                          unit: 'mmHg',
                          classification: r.classification,
                          timestampIso: r.takenAt,
                          onDelete: () => context.read<VitalsBloc>().add(
                            DeleteBpReadingEvent(r.id),
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
}

class _BpSkeleton extends StatelessWidget {
  const _BpSkeleton();

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
