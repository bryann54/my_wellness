import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_clipper.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_home_content.dart';

class AppBarFlexibleHeader extends StatelessWidget {
  final bool isHome;
  final String username;
  final double expandedHeight;
  final double bottomHeight;

  const AppBarFlexibleHeader({
    super.key,
    required this.isHome,
    required this.username,
    required this.expandedHeight,
    required this.bottomHeight,
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
                : const SizedBox.expand(),
          ),
        );
      },
    );
  }
}
