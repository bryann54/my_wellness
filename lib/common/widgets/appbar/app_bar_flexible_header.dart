import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_clipper.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_home_content.dart';

class AppBarFlexibleHeader extends StatelessWidget {
  final bool isHome;
  final String username;
  final double expandedHeight;
  final double bottomHeight;
  final Widget? pageTitle;

  const AppBarFlexibleHeader({
    super.key,
    required this.isHome,
    required this.username,
    required this.expandedHeight,
    required this.bottomHeight,
    this.pageTitle,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cur = constraints.biggest.height;
        final maximumExtent = expandedHeight + statusBarHeight + bottomHeight;
        final minimumExtent = statusBarHeight + kToolbarHeight + bottomHeight;
        final progress = maximumExtent <= minimumExtent
            ? 1.0
            : ((maximumExtent - cur) / (maximumExtent - minimumExtent))
                  .clamp(0.0, 1.0)
                  .toDouble();

        return ClipPath(
          clipper: AppBarClipper(),
          child: Container(
            height: cur,
            color: AppColors.primaryColor,
            child: isHome
                ? AppBarHomeContent(
                    username: username,
                    progress: progress,
                    statusBarHeight: statusBarHeight,
                  )
                : _PageHeaderContent(
                    title: pageTitle,
                    collapseProgress: progress,
                    bottomHeight: bottomHeight,
                  ),
          ),
        );
      },
    );
  }
}

class _PageHeaderContent extends StatelessWidget {
  const _PageHeaderContent({
    required this.title,
    required this.collapseProgress,
    required this.bottomHeight,
  });

  final Widget? title;
  final double collapseProgress;
  final double bottomHeight;

  @override
  Widget build(BuildContext context) {
    final child = title;
    if (child == null) return const SizedBox.expand();

    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            AppBarClipper.radius + bottomHeight + 12,
          ),
          child: Opacity(
            opacity: (1 - collapseProgress).clamp(0.0, 1.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
