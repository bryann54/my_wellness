import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/colors.dart';

class AppBarInitialsAvatar extends StatelessWidget {
  final String initials;

  const AppBarInitialsAvatar({super.key, required this.initials});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => AutoRouter.of(context).push(const AccountRoute()),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.onPrimary.withValues(alpha: 0.18),
          border: Border.all(
            color: cs.onPrimary.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: GoogleFonts.syne(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
