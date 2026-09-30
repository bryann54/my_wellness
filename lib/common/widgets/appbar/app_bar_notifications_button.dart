import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/colors.dart';

class AppBarNotificationsButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onTap;

  const AppBarNotificationsButton({
    super.key,
    this.unreadCount = 0,
    this.onTap,
  });

  bool get _hasUnread => unreadCount > 0;
  bool get _showCount => unreadCount > 9;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _hasUnread
          ? 'Notifications, $unreadCount unread'
          : 'Notifications',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 11,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white.withValues(alpha: 0.22),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap:
                  onTap ??
                  () => AutoRouter.of(context).push(const NotificationsRoute()),
              customBorder: const CircleBorder(),
              splashColor: Colors.white.withValues(alpha: 0.18),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.30),
                      Colors.white.withValues(alpha: 0.14),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.38),
                    width: 1.2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 22,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ),
          ),

          if (_hasUnread)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: AppColors.textOnPrimary,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: _showCount
                      ? Text(
                          '9+',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            height: 1.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
