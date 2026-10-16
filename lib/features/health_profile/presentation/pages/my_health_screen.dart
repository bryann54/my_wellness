import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';

@RoutePage()
class MyHealthScreen extends StatelessWidget {
  const MyHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          CustomAppBar(
            title: AppLocalizations.getString(context, 'common.myHealth'),
            titleHeroTag: HeroTags.homeMyHealth,
            isHome: false,
          ),
        ],
        body: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                AppLocalizations.getString(context, 'common.healthJourney'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
