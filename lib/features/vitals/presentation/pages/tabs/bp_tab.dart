import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_fab.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
import 'package:my_wellness/features/vitals/data/datasources/vitals_capture_remote_datasource.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_capture_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/latest_reading_card.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/reading_history_list.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/vitals_empty_state.dart';

class BpTab extends StatelessWidget {
  const BpTab({super.key});

  static void _startCapture(BuildContext context) {
    context.read<VitalsCaptureBloc>().add(
      const StartVitalsCaptureEvent(VitalsCaptureKind.bp),
    );
    context.router.push(VitalsCaptureIntroRoute(kind: VitalsCaptureKind.bp));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VitalsBloc, VitalsState>(
      buildWhen: (p, c) => p.status != c.status || p.bpReadings != c.bpReadings,
      builder: (context, state) {
        if ((state.status == VitalsStatus.initial ||
                state.status == VitalsStatus.loading) &&
            state.bpReadings.isEmpty) {
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
            icon: Icons.monitor_heart_outlined,
            title: AppLocalizations.getString(context, 'vitals.noBpReadings'),
            subtitle: AppLocalizations.getString(
              context,
              'vitals.noBpReadingsSub',
            ),
            ctaLabel: AppLocalizations.getString(context, 'vitals.addReading'),
            onCta: () => _startCapture(context),
          );
        }

        final latest = state.bpReadings.first;

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: AppFab.compact(
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.getString(context, 'vitals.addReading'),
            onPressed: () => _startCapture(context),
          ),
          body: RefreshIndicator.adaptive(
            onRefresh: () async =>
                context.read<VitalsBloc>().add(const LoadVitalsEvent()),
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
                          kind: ReadingKind.bp,
                          classification: latest.classification,
                          classificationLabel: latest.classificationLabel,
                          primary: '${latest.systolic}/${latest.diastolic}',
                          unit: 'mmHg',
                          timestampIso: latest.takenAt,
                          primaryHeroTag: HeroTags.homeBloodPressureReading,
                          timestampHeroTag: HeroTags.homeBloodPressureTimestamp,
                          secondaryIcon: Icons.favorite_rounded,
                          secondary: latest.pulse == null
                              ? null
                              : AppLocalizations.t(
                                  context,
                                  'vitals.pulseReading',
                                  {'value': '${latest.pulse}'},
                                ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          AppLocalizations.getString(context, 'vitals.history'),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ReadingHistoryList(
                          readings: state.bpReadings
                              .map(
                                (r) => ReadingHistoryRow(
                                  id: r.id,
                                  primary: '${r.systolic}/${r.diastolic}',
                                  unit: 'mmHg',
                                  classification: r.classification,
                                  timestampIso: r.takenAt,
                                  secondary: r.pulse == null
                                      ? null
                                      : AppLocalizations.t(
                                          context,
                                          'vitals.pulseReading',
                                          {'value': '${r.pulse}'},
                                        ),
                                  onDelete: () => context
                                      .read<VitalsBloc>()
                                      .add(DeleteBpReadingEvent(r.id)),
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
}

class _BpSkeleton extends StatelessWidget {
  const _BpSkeleton();

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
