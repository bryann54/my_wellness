
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/l10n.dart';

class CustomFlashyBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomFlashyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activeColor = cs.primary;
    final inactiveColor = cs.onSurface.withValues(alpha: .7);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
        child: FlashyTabBar(
          selectedIndex: currentIndex,
          backgroundColor: cs.surface,
          iconSize: 25,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          showElevation: false,
          onItemSelected: onTap,
          items: [
            // ── Home ────────────────────────────────────────────────
            FlashyTabBarItem(
              icon: FaIcon(
                currentIndex == 0
                    ? FontAwesomeIcons.houseChimneyMedical
                    : FontAwesomeIcons.house,
                color: currentIndex == 0 ? activeColor : inactiveColor,
              ),
              title: Text(
                AppLocalizations.getString(context, 'common.home'),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),

            // ── Assessments ─────────────────────────────────────────
            FlashyTabBarItem(
              icon: FaIcon(
                currentIndex == 1
                    ? FontAwesomeIcons.clipboardCheck
                    : FontAwesomeIcons.clipboardList,
                color: currentIndex == 1 ? activeColor : inactiveColor,
              ),
              title: Text(
                AppLocalizations.getString(context, 'assessments.title'),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),

            // ── Bookings ────────────────────────────────────────────
            FlashyTabBarItem(
              icon: FaIcon(
                currentIndex == 2
                    ? FontAwesomeIcons.solidCalendarCheck
                    : FontAwesomeIcons.calendarCheck,
                color: currentIndex == 2 ? activeColor : inactiveColor,
              ),
              title: Text(
                AppLocalizations.getString(context, 'bookings.title'),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),

            // ── Profile ─────────────────────────────────────────────
            FlashyTabBarItem(
              icon: FaIcon(
                currentIndex == 3
                    ? FontAwesomeIcons.solidCircleUser
                    : FontAwesomeIcons.circleUser,
                color: currentIndex == 3 ? activeColor : inactiveColor,
              ),
              title: Text(
                AppLocalizations.getString(context, 'profile.title'),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
          ],
        ),
      ),
    );
  }
}
