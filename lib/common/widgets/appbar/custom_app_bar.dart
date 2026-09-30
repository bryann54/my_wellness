import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_flexible_header.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';

class CustomAppBar extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final bool isHome;
  final bool isTabRoot;

  final double expandedHeight;
  final PreferredSizeWidget? bottom;

  static const curveExtra = 28.0;
  static const _homeFallbackContentHeight = 90.0;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.isHome = false,
    this.isTabRoot = false,
    this.expandedHeight = 180.0,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (p, c) => p.profile != c.profile,
      builder: (context, state) {
        final topInset = MediaQuery.of(context).padding.top;

        final resolvedExpanded = isHome
            ? topInset + _homeFallbackContentHeight + curveExtra
            : kToolbarHeight + curveExtra;

        return SliverAppBar(
          expandedHeight: resolvedExpanded,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.transparent,

          automaticallyImplyLeading: false,
          leading: isTabRoot ? const SizedBox.shrink() : null,
          leadingWidth: isTabRoot ? 0 : null,
          title: null,
          bottom: bottom,
          flexibleSpace: AppBarFlexibleHeader(
            isHome: isHome,
            username: state.profile?.displayName ?? '',
            title: title,
            actions: [
              if (!isTabRoot && context.router.canPop())
                if (actions != null) ...actions!,
            ],
            expandedHeight: resolvedExpanded,
            bottom: bottom,
          ),
        );
      },
    );
  }
}

class CustomAppBarWithLeading extends StatelessWidget {
  final Widget leading;
  final String? title;
  final List<Widget>? actions;
  final bool isHome;
  final bool isTabRoot;
  final double expandedHeight;
  final PreferredSizeWidget? bottom;

  static const curveExtra = 28.0;

  const CustomAppBarWithLeading({
    super.key,
    required this.leading,
    this.title,
    this.actions,
    this.isHome = false,
    this.isTabRoot = false,
    this.expandedHeight = 180.0,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (p, c) => p.profile != c.profile,
      builder: (context, state) {
        final topInset = MediaQuery.of(context).padding.top;

        final resolvedExpanded = isHome
            ? topInset + 90.0 + curveExtra
            : kToolbarHeight + curveExtra;

        return SliverAppBar(
          expandedHeight: resolvedExpanded,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: null,
          bottom: bottom,
          leadingWidth: isTabRoot ? 0 : 60,
          leading: isTabRoot
              ? const SizedBox.shrink()
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                    child: leading,
                  ),
                ),
          flexibleSpace: AppBarFlexibleHeader(
            isHome: isHome,
            username: state.profile?.displayName ?? '',
            title: title,
            actions: [if (actions != null) ...actions!],
            expandedHeight: resolvedExpanded,
            bottom: bottom,
          ),
        );
      },
    );
  }
}
