import 'package:flutter/material.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';

class CustomFlashyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomFlashyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurface.withValues(alpha: 0.55);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: FlashyTabBar(
          selectedIndex: currentIndex,
          backgroundColor: colorScheme.surface,
          iconSize: 23,
          animationCurve: Curves.easeInOutCubic,
          animationDuration: const Duration(milliseconds: 300),
          showElevation: false,
          onItemSelected: onTap,
          items: [
            _buildItem(
              context: context,
              index: 0,
              activeIcon: FontAwesomeIcons.stethoscope,
              inactiveIcon: FontAwesomeIcons.stethoscope,
              title: AppLocalizations.getString(context, 'common.home'),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            _buildItem(
              context: context,
              index: 1,
              activeIcon: FontAwesomeIcons.heartPulse,
              inactiveIcon: FontAwesomeIcons.heartPulse,
              title: AppLocalizations.getString(context, 'assessment.titlebot'),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            _buildItem(
              context: context,
              index: 2,
              activeIcon: FontAwesomeIcons.calendarCheck,
              inactiveIcon: FontAwesomeIcons.calendar,
              title: AppLocalizations.getString(context, 'bookings.title'),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            _buildItem(
              context: context,
              index: 3,
              activeIcon: FontAwesomeIcons.leaf,
              inactiveIcon: FontAwesomeIcons.leaf,
              title: AppLocalizations.getString(context, 'wellness.title'),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            _buildItem(
              context: context,
              index: 4,
              activeIcon: FontAwesomeIcons.userDoctor,
              inactiveIcon: FontAwesomeIcons.user,
              title: AppLocalizations.getString(context, 'profile.title'),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
          ],
        ),
      ),
    );
  }

  FlashyTabBarItem _buildItem({
    required BuildContext context,
    required int index,
    required FaIconData activeIcon,
    required FaIconData inactiveIcon,
    required String title,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isActive = currentIndex == index;

    return FlashyTabBarItem(
      icon: FaIcon(
        isActive ? activeIcon : inactiveIcon,
        color: isActive ? activeColor : inactiveColor,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      activeColor: activeColor,
      inactiveColor: inactiveColor,
    );
  }
}
