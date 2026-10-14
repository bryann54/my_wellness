import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/home/presentation/bloc/home_bloc.dart';
import 'package:my_wellness/features/home/presentation/widgets/assessment_progress_card.dart';
import 'package:my_wellness/features/home/presentation/widgets/quick_action_row.dart';
import 'package:my_wellness/features/home/presentation/widgets/vitals_tile.dart';
import 'package:my_wellness/features/notifications/presentation/bloc/notifications_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    final displayName = context.select<AccountBloc, String>(
      (bloc) => bloc.state.profile?.displayName.trim() ?? '',
    );
    final firstName = displayName.isEmpty
        ? ''
        : displayName.split(RegExp(r'\s+')).first;
    final greeting = firstName.isEmpty
        ? AppLocalizations.getString(context, 'homeDashboard.welcomeFallback')
        : AppLocalizations.t(context, 'homeDashboard.welcome', {
            'name': firstName,
          });
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final overlayStyle = theme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HomeBrandRow(topInset: MediaQuery.paddingOf(context).top),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: _GreetingRow(greeting: greeting, firstName: firstName),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _SectionHeading(
                        title: AppLocalizations.getString(
                          context,
                          'homeDashboard.quickActions',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const QuickActionRow(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeading(
                          title: AppLocalizations.getString(
                            context,
                            'homeDashboard.healthOverview',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Expanded(
                                child: VitalsTile(kind: VitalsTileKind.bp),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              const Expanded(
                                child: VitalsTile(kind: VitalsTileKind.bs),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const AssessmentProgressCard(),
                      ],
                    ),
                  ),
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
    );
  }
}

class _HomeBrandRow extends StatelessWidget {
  const _HomeBrandRow({required this.topInset});

  final double topInset;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      AppSpacing.lg,
      topInset + AppSpacing.sm,
      AppSpacing.lg,
      AppSpacing.sm,
    ),
    child: Row(
      children: [
        Hero(
          tag: HeroTags.authLogo,
          flightShuttleBuilder: (_, __, direction, ___, toHero) =>
              toHero.widget,
          child: SizedBox(
            width: 44,
            height: 40,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                minWidth: 88,
                maxWidth: 88,
                minHeight: 40,
                maxHeight: 40,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 58,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.health_and_safety_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        BlocBuilder<NotificationsBloc, NotificationsState>(
          buildWhen: (previous, current) =>
              previous.unreadCount != current.unreadCount,
          builder: (context, state) {
            final unreadCount = state.unreadCount;
            return IconButton(
              tooltip: AppLocalizations.getString(
                context,
                'settings.notifications',
              ),
              onPressed: () => context.router.push(const NotificationsRoute()),
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(unreadCount > 9 ? '9+' : '$unreadCount'),
                child: const Icon(Icons.notifications_none_rounded),
              ),
            );
          },
        ),
      ],
    ),
  );
}

class _GreetingRow extends StatelessWidget {
  const _GreetingRow({required this.greeting, required this.firstName});

  final String greeting;
  final String firstName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    if (firstName.isEmpty) {
      return Text(
        greeting,
        style: textTheme.headlineSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    final greetingLead = greeting.replaceFirst(firstName, '').trimRight();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          greetingLead,
          style: textTheme.titleMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            firstName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
  );
}
