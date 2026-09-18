// lib/common/widgets/custom_flashy_bottom_nav.dart
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
            // Home
            FlashyTabBarItem(
              icon: FaIcon(
                currentIndex == 0
                    ? FontAwesomeIcons.houseFire
                    : FontAwesomeIcons.house,
                color: currentIndex == 0 ? activeColor : inactiveColor,
              ),
              title: Text(
                AppLocalizations.getString(context, 'common.home'),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),

            FlashyTabBarItem(
              icon: FaIcon(
                currentIndex == 1
                    ? FontAwesomeIcons.solidComments
                    : FontAwesomeIcons.comments,
                color: currentIndex == 1 ? activeColor : inactiveColor,
              ),
              title: Text(
                AppLocalizations.getString(context, 'common.chats'),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),

            // Documents
            FlashyTabBarItem(
              icon: FaIcon(
                currentIndex == 2
                    ? FontAwesomeIcons.solidFileLines
                    : FontAwesomeIcons.fileContract,
                color: currentIndex == 2 ? activeColor : inactiveColor,
              ),
              title: Text(
                AppLocalizations.getString(context, 'documents.documents'),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),

            // resources
            FlashyTabBarItem(
              icon: FaIcon(
                FontAwesomeIcons.solidNewspaper,
                color: currentIndex == 3 ? activeColor : inactiveColor,
              ),
              title: Text(
                AppLocalizations.getString(context, 'common.resources'),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),

            // Profile
            FlashyTabBarItem(
              icon: FaIcon(
                currentIndex == 4
                    ? FontAwesomeIcons.gears
                    : FontAwesomeIcons.gear,
                color: currentIndex == 4 ? activeColor : inactiveColor,
              ),
              title: Text(
                AppLocalizations.getString(context, 'settings.title'),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
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
