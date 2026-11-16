import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
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
  final _scroll = ScrollController();
  final _measurementsKey = GlobalKey();
  final _clinicalKey = GlobalKey();
  final _treatmentKey = GlobalKey();
  final _journeyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _tabs.addListener(() {
      if (_tabs.indexIsChanging) return;
      _scrollToTab(_tabs.index);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _scroll.dispose();
    super.dispose();
  }

  GlobalKey _keyForTab(int index) => switch (index) {
    0 => _measurementsKey,
    1 => _clinicalKey,
    2 => _treatmentKey,
    _ => _journeyKey,
  };

  void _scrollToTab(int index) {
    final ctx = _keyForTab(index).currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  Future<void> _refresh() async {
    final bloc = context.read<HealthHistoryBloc>();
    bloc.add(const LoadHealthHistoryEvent(silent: true));
    await bloc.stream.firstWhere((s) => !s.refreshing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HealthHistoryBloc, HealthHistoryState>(
        builder: (context, state) {
          final history = state.history;
          final isFirstLoad =
              state.status == HealthHistoryStatus.loading && history == null;
          final isHardError =
              state.status == HealthHistoryStatus.error && history == null;

          if (isHardError) {
            return _HistoryError(
              message: state.errorMessage,
              onRetry: () => context.read<HealthHistoryBloc>().add(
                const LoadHealthHistoryEvent(),
              ),
            );
          }

          return RefreshIndicator.adaptive(
            onRefresh: _refresh,
            child: NestedScrollView(
              controller: _scroll,
              headerSliverBuilder: (context, _) => [
                const CustomAppBar(
                  title: 'My Medical History',
                  titleHeroTag: HeroTags.homeMyHealth,
                  isHome: false,
                ),
                _JumpLinksSliver(controller: _tabs, onJump: _scrollToTab),
              ],
              body: isFirstLoad
                  ? const _HistorySkeleton()
                  : _HistoryBody(
                      history: history ?? const HealthHistory(),
                      state: state,
                      sectionKeys: {
                        'measurements': _measurementsKey,
                        'clinical': _clinicalKey,
                        'treatment': _treatmentKey,
                        'journey': _journeyKey,
                      },
                      onRefreshRequested: _refresh,
                    ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Jump links — sticky segmented control at the top of the scroll
// ─────────────────────────────────────────────────────────────────────────────

class _JumpLinksSliver extends StatelessWidget {
  const _JumpLinksSliver({required this.controller, required this.onJump});

  final TabController controller;
  final ValueChanged<int> onJump;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _JumpLinksDelegate(
        background: cs.surface,
        border: cs.outlineVariant.withValues(alpha: .4),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                Expanded(
                  child: _JumpChip(
                    label: _tabsLabels[i],
                    active: controller.index == i,
                    onTap: () => onJump(i),
                  ),
                ),
                if (i != 3) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static const _tabsLabels = [
    'Measurements',
    'Clinical',
    'Treatment',
    'Journey',
  ];
}

class _JumpLinksDelegate extends SliverPersistentHeaderDelegate {
  _JumpLinksDelegate({
    required this.child,
    required this.background,
    required this.border,
  });

  final Widget child;
  final Color background;
  final Color border;

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: 56,
      color: background,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: border)),
        ),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _JumpLinksDelegate old) =>
      old.background != background || old.border != border;
}

class _JumpChip extends StatelessWidget {
  const _JumpChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: active ? cs.primary : cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: active ? cs.onPrimary : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({
    required this.history,
    required this.state,
    required this.sectionKeys,
    required this.onRefreshRequested,
  });

  final HealthHistory history;
  final HealthHistoryState state;
  final Map<String, GlobalKey> sectionKeys;
  final Future<void> Function() onRefreshRequested;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      controller: PrimaryScrollController.maybeOf(context),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // Connection card first — it's the "how does data get here" gate.
        // If it's not connected, everything below is either empty or stale.
        ConnectionCard(onHistoryRefresh: onRefreshRequested),
        const SizedBox(height: 20),

        if (state.errorMessage != null && !history.isEmpty) ...[
          _InlineNotice(message: state.errorMessage!),
          const SizedBox(height: 16),
        ],

        // 01 — Measurements
        _SectionShell(
          key: sectionKeys['measurements'],
          number: '01',
          title: 'Recent clinical measurements',
          subtitle:
              'Measurements recorded through health monitoring or connected records.',
          child: MeasurementsSection(history: history),
        ),
        const SizedBox(height: 24),

        // 02 — Clinical history
        _SectionShell(
          key: sectionKeys['clinical'],
          number: '02',
          title: 'Conditions & allergies',
          subtitle:
              'Clinical diagnoses and documented allergies or adverse reactions.',
          child: ClinicalSection(history: history),
        ),
        const SizedBox(height: 24),

        // 03 — Treatment
        _SectionShell(
          key: sectionKeys['treatment'],
          number: '03',
          title: 'Investigations, treatment & prevention',
          subtitle:
              'Available laboratory, procedure, prescription and immunization information.',
          child: TreatmentSection(history: history),
        ),
        const SizedBox(height: 24),

        // 04 — Journey
        _SectionShell(
          key: sectionKeys['journey'],
          number: '04',
          title: 'Health journey',
          subtitle: 'Completed health checks and recommended care.',
          child: JourneySection(history: history),
        ),

        const SizedBox(height: 28),
        _Footnote(
          text:
              '"No record" means information is not currently available on this page. '
              'It does not confirm that a condition, medication, procedure or vaccination has never occurred.',
          color: cs.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        _Footnote(
          text:
              'My Wellness Health · Health information and care navigation. This page '
              'summarizes recorded information and does not replace assessment or advice '
              'from a licensed healthcare professional.',
          color: cs.onSurfaceVariant.withValues(alpha: .75),
        ),
      ],
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String number;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NumberBadge(number: number),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number});
  final String number;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        number,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: cs.onPrimaryContainer,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
        ),
      ),
    );
  }
}

class _Footnote extends StatelessWidget {
  const _Footnote({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(height: 1.55, color: color),
  );
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: AppRadius.mdAll,
    ),
    child: Text(message),
  );
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
    children: const [
      ShimmerCard(height: 200, radius: 20),
      SizedBox(height: 24),
      ShimmerLine(width: 220, height: 22),
      SizedBox(height: 14),
      ShimmerCard(height: 180, radius: 18),
      SizedBox(height: 24),
      ShimmerLine(width: 180, height: 22),
      SizedBox(height: 14),
      ShimmerCard(height: 140, radius: 18),
    ],
  );
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});
  final String? message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 42),
          const SizedBox(height: 12),
          Text(
            message ?? 'We couldn’t load your medical history.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppPrimaryButton(onPressed: onRetry, label: 'Try again'),
        ],
      ),
    ),
  );
}
