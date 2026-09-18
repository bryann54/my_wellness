import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/l10n.dart';

class ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.getString(context, 'common.error'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.getString(context, 'profile.retry')),
          ),
        ],
      ),
    );
  }
}
