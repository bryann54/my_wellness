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
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeDashboardEvent());
    context.read<VitalsBloc>().add(const LoadVitalsSummaryEvent());
  }

  Future<void> _refresh() async {
    final homeBloc = context.read<HomeBloc>();
    homeBloc.add(const LoadHomeDashboardEvent());
    context.read<VitalsBloc>().add(const LoadVitalsSummaryEvent());
    await homeBloc.stream.firstWhere(
      (state) => state.status != HomeDashboardStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = context.select<AccountBloc, String>(
      (bloc) => bloc.state.profile?.displayName.trim() ?? '',
    );
    final firstName = displayName.isEmpty
        ? ''
        : displayName.split(RegExp(r'\s+')).first;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final overlayStyle = theme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const HomeAppBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(
                  child: _GreetingBlock(firstName: firstName),
                ),
              ),
              // Active screenings first: it's the one actionable item.
              // The card collapses to nothing (including its own bottom
              // spacing) when there are no sessions.
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: const [
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

class _GreetingBlock extends StatelessWidget {
  const _GreetingBlock({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final greetingLead = AppLocalizations.getString(
      context,
      'homeDashboard.welcomeFallback',
    );

    if (firstName.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greetingLead,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.5,
              color: colors.onSurface,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              AppLocalizations.getString(context, 'common.hello'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -0.6,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
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
