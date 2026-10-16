import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/home/presentation/bloc/home_bloc.dart';
import 'package:my_wellness/features/home/presentation/widgets/assessment_progress_card.dart';
import 'package:my_wellness/features/home/presentation/widgets/home_app_bar.dart';
import 'package:my_wellness/features/home/presentation/widgets/quick_action_row.dart';
import 'package:my_wellness/features/home/presentation/widgets/vitals_tile.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final _whitespace = RegExp(r'\s+');

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<HomeBloc>().add(const LoadHomeDashboardEvent());
    context.read<VitalsBloc>().add(const LoadVitalsSummaryEvent());
  }

  Future<void> _refresh() async {
    final home = context.read<HomeBloc>();
    final vitals = context.read<VitalsBloc>();
    final homeDone = home.stream.firstWhere(
      (s) => s.status != HomeDashboardStatus.loading,
    );
    final vitalsDone = vitals.stream.firstWhere(
      (s) => s.status != VitalsStatus.loading,
    );

    _load();

    try {
      await Future.wait<Object?>([
        homeDone,
        vitalsDone,
      ]).timeout(const Duration(seconds: 10), onTimeout: () => const []);
    } catch (_) {
    }
  }

  String _greeting(BuildContext context) {
    final displayName = context.select<AccountBloc, String>(
      (bloc) => bloc.state.profile?.displayName.trim() ?? '',
    );
    if (displayName.isEmpty) return '';
    final firstName = displayName.split(_whitespace).first;
    return '${AppLocalizations.getString(context, 'common.hello')}, $firstName';
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _greeting(context);

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final overlayStyle = theme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: RefreshIndicator.adaptive(
          onRefresh: _refresh,
          edgeOffset: MediaQuery.paddingOf(context).top + kToolbarHeight,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              HomeAppBar(greeting: greeting),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(child: AssessmentProgressCard()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(
                        label: AppLocalizations.getString(
                          context,
                          'homeDashboard.healthOverview',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: VitalsTile(kind: VitalsTileKind.bp),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: VitalsTile(kind: VitalsTileKind.bs),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(
                        label: AppLocalizations.getString(
                          context,
                          'homeDashboard.quickActions',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const QuickActionRow(),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 104 + MediaQuery.paddingOf(context).bottom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        fontSize: 13,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
