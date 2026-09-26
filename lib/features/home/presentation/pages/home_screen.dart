// lib/features/home/presentation/pages/home_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/home/presentation/widgets/vitals_tile.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(isHome: true, expandedHeight: 220),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList.list(
              children: const [
                Row(
                  children: [
                    Expanded(child: VitalsTile(kind: VitalsTileKind.bp)),
                    SizedBox(width: 12),
                    Expanded(child: VitalsTile(kind: VitalsTileKind.bs)),
                  ],
                ),
                SizedBox(height: 10),
                Divider(),

                // Next sections to add:
                //   - KnowYourRiskCard (assessments)
                //   - BookCheckUpBanner (appointments)
                //   - MedicationsCard (list preview)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
