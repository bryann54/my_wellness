import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';

@RoutePage()
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          CustomAppBar(
            title: AppLocalizations.getString(context, 'bookings.title'),
            isHome: false,
          ),
        ],
        body: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                AppLocalizations.getString(context, 'bookings.title'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}