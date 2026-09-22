// features/main_screen.dart
import 'package:auto_route/auto_route.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/widgets/bottom_nav_widget.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      lazyLoad: false,
      homeIndex: 1,
      routes: const [
        HomeRoute(),
        AssessmentsRoute(),
        BookingsRoute(),
        WellnessRoute(),
        AccountRoute(),
        
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return CustomFlashyBottomNav(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
        );
      },
    );
  }
}
