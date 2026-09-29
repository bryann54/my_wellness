import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/app_bar_notifications_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final expandedOpacity = (1.0 - progress * 2.2).clamp(0.0, 1.0);
    final collapsedOpacity = ((progress - 0.75) / 0.25).clamp(0.0, 1.0);

    return Stack(
      children: [
        Positioned(
          top: statusBarHeight,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: expandedOpacity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        AppLocalizations.getString(context, 'common.hello'),
                        style: GoogleFonts.habibi(
                          fontSize: 16,
                          height: 1.1,
                          color: AppColors.textOnPrimary.withValues(
                            alpha: 0.65,
                          ),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          username.isNotEmpty ? username : '...',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            height: 1.1,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textOnPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppBarNotificationsButton(),
                      // BlocBuilder<NotificationsBloc, NotificationsState>(
                      //   buildWhen: (p, c) => p.unreadCount != c.unreadCount,
                      //   builder: (context, state) => AppBarNotificationsButton(
                      //     unreadCount: state.unreadCount,
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  const QuickActionRow(),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: statusBarHeight,
          left: 60,
          right: 60,
          height: kToolbarHeight,
          child: IgnorePointer(
            ignoring: collapsedOpacity < 0.5,
            child: Opacity(
              opacity: collapsedOpacity,
              child: Center(
                child: Text(
                  username.isNotEmpty ? username : '...',
                  style: GoogleFonts.inter(
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
        ),

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
