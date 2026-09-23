
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_initials_avatar.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/home/presentation/widgets/quick_action_row.dart';

class AppBarHomeContent extends StatelessWidget {
  final String username;
  final List<Widget>? actions;
  final double progress;
  final double statusBarHeight;
  final double bottomHeight;

  const AppBarHomeContent({
    super.key,
    required this.username,
    required this.actions,
    required this.progress,
    required this.statusBarHeight,
    required this.bottomHeight,
  });

  String get _initials {
    final parts = username
        .replaceAll(RegExp(r'[^a-zA-Z ]'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final expandedOpacity = (1.0 - progress * 2).clamp(0.0, 1.0);
    final collapsedOpacity = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);

    return Stack(
      children: [
        Positioned(
          top: statusBarHeight + 12,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 105,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.error_outline_outlined,
                    size: 45,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              AppBarInitialsAvatar(initials: _initials),
            ],
          ),
        ),

        //greeting + name + location + chips
        Positioned(
          top: statusBarHeight + 90,
          left: 20,
          right: 20,
          bottom: bottomHeight + CustomAppBar.curveExtra,
          child: Opacity(
            opacity: expandedOpacity,
            child: OverflowBox(
              maxHeight: double.infinity,
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.getString(context, 'common.hello'),
                        style: GoogleFonts.habibi(
                          fontSize: 18,
                          color: AppColors.textOnPrimary.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          username.isNotEmpty ? username : '...',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textOnPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  const QuickActionRow(),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: statusBarHeight,
          left: 70,
          right: 70,
          height: kToolbarHeight,
          child: Opacity(
            opacity: collapsedOpacity,
            child: Center(
              child: Text(
                username.isNotEmpty ? username : '...',
                style: GoogleFonts.syne(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textOnPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),

        // ── Extra actions ────────────────────────────────────────────────
        if (actions != null)
          Positioned(
            top: statusBarHeight,
            right: 4,
            child: Row(children: actions!),
          ),
      ],
    );
  }
}
