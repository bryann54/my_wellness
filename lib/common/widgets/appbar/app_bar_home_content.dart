// lib/common/widgets/appbar/app_bar_home_content.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_initials_avatar.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/home/presentation/widgets/quick_action_row.dart';

class AppBarHomeContent extends StatelessWidget {
  final String username;
  // final String? location;
  final List<Widget>? actions;
  final double progress;
  final double statusBarHeight;
  final double bottomHeight;

  const AppBarHomeContent({
    super.key,
    required this.username,
    // required this.location,
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
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.shield_rounded,
                    size: 45,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              AppBarInitialsAvatar(initials: _initials),
            ],
          ),
        ),

        // ── Expanded content (greeting + name + location + chips) ────────
        Positioned(
          top: statusBarHeight + 72,
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
                  // ── Greeting ───────────────────────────────────────────
                  Text(
                    AppLocalizations.getString(context, 'common.hello'),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textOnPrimary.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // ── Name + location ────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          username.isNotEmpty ? username : '...',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textOnPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // if (locationName != null) ...[
                      //   const SizedBox(width: 8),
                      //   Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(
                      //         Icons.location_on_rounded,
                      //         size: 13,
                      //         color: AppColors.textOnPrimary.withValues(
                      //           alpha: 0.54,
                      //         ),
                      //       ),
                      //       const SizedBox(width: 3),
                      //       Text(
                      //         locationName,
                      //         style: GoogleFonts.inter(
                      //           fontSize: 12,
                      //           color: AppColors.textOnPrimary.withValues(
                      //             alpha: 0.54,
                      //           ),
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ],
                      //   ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.2),
                      // ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Quick action chips ─────────────────────────────────
                  const QuickActionRow(),
                ],
              ),
            ),
          ),
        ),

        // ── Collapsed title (fades in as bar collapses) ──────────────────
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
                  fontSize: 18,
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
