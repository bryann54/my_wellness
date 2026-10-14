import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/notifications/presentation/bloc/notifications_bloc.dart';

/// Pinned header for the home screen. Replaces `_BrandRow`.
///
/// SliverAppBar handles the status-bar inset itself, and being pinned means
/// scrolled content slides *under* an opaque surface instead of colliding with
/// the clock / Dynamic Island.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      titleSpacing: AppSpacing.lg,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      // Hairline shadow only once content has scrolled beneath the bar.
      scrolledUnderElevation: 0.5,
      shadowColor: colors.outlineVariant,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Hero(
          tag: HeroTags.authLogo,
          flightShuttleBuilder: (_, __, direction, ___, toHero) =>
              toHero.widget,
          child: Image.asset(
            'assets/images/logo.png',
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.health_and_safety_rounded,
              color: colors.primary,
              size: 36,
            ),
          ),
        ),
      ),
      actions: [
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
              icon: unreadCount > 0
                  ? Badge(
                      label: Text(unreadCount > 9 ? '9+' : '$unreadCount'),
                      backgroundColor: colors.error,
                      child: const Icon(Icons.notifications_none_rounded),
                    )
                  : const Icon(Icons.notifications_none_rounded),
            );
          },
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}
