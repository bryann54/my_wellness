import 'package:flutter/material.dart';

class SafeUnavailablePage extends StatelessWidget {
  const SafeUnavailablePage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This area will be available when its approved My Wellness '
              'service and privacy contract are ready.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
}
