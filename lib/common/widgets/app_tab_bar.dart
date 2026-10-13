import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';

class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<String> tabs;

  const AppTabBar({super.key, required this.controller, required this.tabs});

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      indicatorColor: AppColors.textOnPrimary,
      indicatorWeight: 2,
      indicatorSize: TabBarIndicatorSize.label,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      labelStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelColor: AppColors.background,
      unselectedLabelColor: AppColors.background.withValues(alpha: 0.68),
      dividerColor: Colors.transparent,
      tabs: tabs.map((t) => Tab(text: t)).toList(),
    );
  }
}
