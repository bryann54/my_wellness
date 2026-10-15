import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, required this.greeting});
  final String greeting;

  static const _toolbarHeight = 64.0;
  static const _collapseDistance = 40.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      toolbarHeight: _toolbarHeight,
      expandedHeight: _toolbarHeight + _collapseDistance,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0.5,
      shadowColor: colors.outlineVariant,
      titleSpacing: 0,
      actions: [
        BlocBuilder<NotificationsBloc, NotificationsState>(
          buildWhen: (previous, current) =>
              previous.unreadCount != current.unreadCount,
          builder: (context, state) {
            final unreadCount = state.unreadCount;
            const icon = Hero(
              tag: HeroTags.homeNotifications,
              child: Icon(
                PhosphorIconsRegular.bell,size: 30),
            );
            return IconButton(
              tooltip: AppLocalizations.getString(
                context,
                'settings.notifications',
              ),
              onPressed: () => context.router.push(const NotificationsRoute()),
              icon: unreadCount > 0
                  ? Badge(
                      label: Text(unreadCount > 9 ? '9+' : '$unreadCount'),
                      backgroundColor: colors.error,
                      child: icon,
                    )
                  : icon,
            );
          },
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      flexibleSpace: _FlexibleHeader(
        greeting: greeting,
        toolbarHeight: _toolbarHeight,
      ),
    );
  }
}

class _FlexibleHeader extends StatelessWidget {
  const _FlexibleHeader({required this.greeting, required this.toolbarHeight});

  final String greeting;
  final double toolbarHeight;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final topInset = MediaQuery.paddingOf(context).top;
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    var progress = 0.0;
    if (settings != null) {
      final range = settings.maxExtent - settings.minExtent;
      if (range > 0) {
        progress = ((settings.maxExtent - settings.currentExtent) / range)
            .clamp(0.0, 1.0);
      }
    }

    final hasGreeting = greeting.isNotEmpty;

  
    final logoOpacity = hasGreeting
        ? Curves.easeIn.transform((1 - progress * 2).clamp(0.0, 1.0))
        : 1.0;
    final greetingOpacity = hasGreeting
        ? Curves.easeOut.transform(((progress - 0.5) * 2).clamp(0.0, 1.0))
        : 0.0;

    final logoShift = -30.0 * progress;
    final greetingShift = 20.0 * (1 - greetingOpacity);

    return Container(
      color: colors.surface,
      child: Stack(
        children: [
          Positioned(
            left: AppSpacing.lg,
            top: topInset,
            height: toolbarHeight,
            child: IgnorePointer(
              ignoring: logoOpacity == 0,
              child: Opacity(
                opacity: logoOpacity,
                child: Transform.translate(
                  offset: Offset(0, logoShift),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Hero(
                      tag: HeroTags.authLogo,
                      flightShuttleBuilder: (_, __, direction, ___, toHero) =>
                          toHero.widget,
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 48,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          PhosphorIconsRegular.heart,
                          color: colors.primary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (hasGreeting)
            Positioned(
              left: AppSpacing.lg,
              right: 60, 
              top: topInset,
              height: toolbarHeight,
              child: Opacity(
                opacity: greetingOpacity,
                child: Transform.translate(
                  offset: Offset(0, greetingShift),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                      
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
