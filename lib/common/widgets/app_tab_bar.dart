// lib/common/widgets/app_tab_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      indicatorColor: Colors.white,
      indicatorWeight: 2.5,
      labelStyle: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      dividerColor: Colors.transparent,
      tabs: tabs.map((t) => Tab(text: t)).toList(),
    );
  }
}
