import 'package:flutter/material.dart';
import 'package:my_wellness/common/constatnts/routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('My Wellness')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            Text('Your preventive-health journey',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Text(
                'Plan actions and booking details are shown only after approved, authenticated server data is available.'),
            SizedBox(height: 24),
            _RouteTile('Assessments', AppRoutes.assessments),
            _RouteTile('Consent and privacy', AppRoutes.consent),
            _RouteTile('Care plan', AppRoutes.carePlan),
            _RouteTile('Results', AppRoutes.results),
            _RouteTile('Appointments', AppRoutes.appointments),
            _RouteTile('Care navigation', AppRoutes.careNavigation),
            _RouteTile('Vitals', AppRoutes.vitals),
            _RouteTile('Resources', AppRoutes.resources),
            _RouteTile('Profile and support', AppRoutes.profile),
          ],
        ),
      );
}

class _RouteTile extends StatelessWidget {
  const _RouteTile(this.title, this.route);
  final String title;
  final String route;
  @override
  Widget build(BuildContext context) => Card(
      child: ListTile(
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).pushNamed(route)));
}
