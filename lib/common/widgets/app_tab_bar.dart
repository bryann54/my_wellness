import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';

class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<String> tabs;

  const AppTabBar({super.key, required this.controller, required this.tabs});

  @override
  Size get preferredSize => const Size.fromHeight(46);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      indicatorColor: AppColors.background,
      indicatorWeight: 2.5,
      labelStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      labelColor: AppColors.background,
      unselectedLabelColor: AppColors.background,
      dividerColor: Colors.transparent,
      tabs: tabs.map((t) => Tab(text: t)).toList(),
    );
  }
}
