import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';

@RoutePage()
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            title: AppLocalizations.getString(
              context,
              'common.notifications',
            ),
          ),

          // Your content below
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ListTile(
                  title: Text('Notification #$index'),
                  subtitle: const Text('This is a notification detail.'),
                  leading: const Icon(Icons.notifications),
                  onTap: () {},
                ),
                childCount: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
