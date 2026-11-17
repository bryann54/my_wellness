import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/features/health_profile/domain/entities/health_history.dart';
import 'package:my_wellness/features/health_profile/presentation/bloc/health_history_bloc.dart';
import 'package:my_wellness/features/health_profile/presentation/widgets/connection_card.dart';
import 'package:my_wellness/features/health_profile/presentation/widgets/history_sections.dart';

@RoutePage()
class MyHealthScreen extends StatelessWidget {
  const MyHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = getIt<HealthHistoryBloc>();
    if (bloc.state.status == HealthHistoryStatus.initial) {
      bloc.add(const LoadHealthHistoryEvent());
    }
    return BlocProvider.value(value: bloc, child: const _HealthHistoryView());
  }
}

class _HealthHistoryView extends StatefulWidget {
  const _HealthHistoryView();

  @override
  State<_HealthHistoryView> createState() => _HealthHistoryViewState();
}

class _HealthHistoryViewState extends State<_HealthHistoryView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final bloc = context.read<HealthHistoryBloc>();
    bloc.add(const LoadHealthHistoryEvent(silent: true));
    await bloc.stream.firstWhere((state) => !state.refreshing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HealthHistoryBloc, HealthHistoryState>(
        builder: (context, state) {
          final history = state.history;
          final firstLoad =
              state.status == HealthHistoryStatus.loading && history == null;
          final hardError =
              state.status == HealthHistoryStatus.error && history == null;

          if (hardError) {
            return _HistoryError(
              onRetry: () => context.read<HealthHistoryBloc>().add(
                const LoadHealthHistoryEvent(),
              ),
            );
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              CustomAppBar(
                title: _t(context, 'healthHistory.title'),
                titleHeroTag: HeroTags.homeMyHealth,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(context, 'healthHistory.subtitle'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ConnectionCard(onHistoryRefresh: _refresh),
                      if (state.errorMessage != null && history != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        const _RefreshWarning(),
                      ],
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabHeaderDelegate(
                  TabBar(
                    controller: _tabs,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerHeight: 1,
                    tabs: [
                      Tab(text: _t(context, 'healthHistory.measurementsTab')),
                      Tab(text: _t(context, 'healthHistory.clinicalTab')),
                      Tab(text: _t(context, 'healthHistory.careRecordsTab')),
                    ],
                  ),
                ),
              ),
            ],
            body: firstLoad
                ? const _HistorySkeleton()
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _Refreshable(
                        onRefresh: _refresh,
                        child: MeasurementsSection(
                          history: history ?? const HealthHistory(),
                        ),
                      ),
                      _Refreshable(
                        onRefresh: _refresh,
                        child: ClinicalSection(
                          history: history ?? const HealthHistory(),
                        ),
                      ),
                      _Refreshable(
                        onRefresh: _refresh,
                        child: CareRecordsSection(
                          history: history ?? const HealthHistory(),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _Refreshable extends StatelessWidget {
  const _Refreshable({required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      RefreshIndicator.adaptive(onRefresh: onRefresh, child: child);
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _TabHeaderDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Material(color: Theme.of(context).colorScheme.surface, child: tabBar);

  @override
  bool shouldRebuild(covariant _TabHeaderDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}

class _RefreshWarning extends StatelessWidget {
  const _RefreshWarning();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.sync_problem_outlined, color: colors.onErrorContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _t(context, 'healthHistory.refreshFailed'),
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.md),
    children: const [
      ShimmerBox(height: 28, width: 180),
      SizedBox(height: AppSpacing.md),
      ShimmerBox(height: 92),
      SizedBox(height: AppSpacing.sm),
      ShimmerBox(height: 92),
      SizedBox(height: AppSpacing.sm),
      ShimmerBox(height: 220),
    ],
  );
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      CustomAppBar(
        title: _t(context, 'healthHistory.title'),
        titleHeroTag: HeroTags.homeMyHealth,
      ),
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _t(context, 'healthHistory.loadFailedTitle'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _t(context, 'healthHistory.loadFailedBody'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  onPressed: onRetry,
                  label: _t(context, 'common.retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

String _t(BuildContext context, String key) =>
    AppLocalizations.getString(context, key);
