import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';

class AppBarInnerContent extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final double statusBarHeight;
  final double bottomHeight;

  const AppBarInnerContent({
    super.key,
    required this.title,
    required this.actions,
    required this.statusBarHeight,
    required this.bottomHeight,
  });

  @override
  Widget build(BuildContext context) {
    final router = AutoRouter.of(context);

    return Stack(
      children: [
        if (router.canPop())
          Positioned(
            top: statusBarHeight + 4,
            left: 4,
            bottom: bottomHeight + CustomAppBar.curveExtra,
            child: IconButton(
              onPressed: () => router.maybePop(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textOnPrimary,
                size: 20,
              ),
            ),
          ),

        // ── Centered title ───────────────────────────────────────────────
        Positioned(
          top: statusBarHeight,
          left: 56,
          right: 56,
          bottom: 0,
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.syne(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ),

        // ── Right actions ────────────────────────────────────────────────
        if (actions != null)
          Positioned(
            top: statusBarHeight + 4,
            right: 4,
            bottom: bottomHeight + CustomAppBar.curveExtra,
            child: Row(mainAxisSize: MainAxisSize.min, children: actions!),
          ),
      ],
    );
  }
}
