import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_clipper.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_home_content.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_inner_content.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';

class AppBarFlexibleHeader extends StatelessWidget {
  final bool isHome;
  final String username;
  // final String? location;
  final String? title;
  final List<Widget>? actions;
  final double expandedHeight;
  final PreferredSizeWidget? bottom;

  const AppBarFlexibleHeader({
    super.key,
    required this.isHome,
    required this.username,
    // required this.location,
    required this.title,
    required this.actions,
    required this.expandedHeight,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomHeight = bottom?.preferredSize.height ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cur = constraints.biggest.height;
        final collapsed =
            statusBarHeight + kToolbarHeight + CustomAppBar.curveExtra;
        final progress = expandedHeight <= collapsed
            ? 1.0
            : ((expandedHeight - cur) / (expandedHeight - collapsed)).clamp(
                0.0,
                1.0,
              );

        return ClipPath(
          clipper: AppBarClipper(),
          child: Container(
            height: cur,
            color: AppColors.primaryColor,
            child: isHome
                ? AppBarHomeContent(
                    username: username,
                    // location: location,
                    actions: actions,
                    progress: progress,
                    statusBarHeight: statusBarHeight,
                    bottomHeight: bottomHeight,
                  )
                : AppBarInnerContent(
                    title: title ?? '',
                    actions: actions,
                    statusBarHeight: statusBarHeight,
                    bottomHeight: bottomHeight,
                  ),
          ),
        );
      },
    );
  }
}
