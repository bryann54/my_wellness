import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/features/subscriptions/presentation/bloc/subscriptions_bloc.dart';

class RestoreButton extends StatelessWidget {
  const RestoreButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BlocBuilder<SubscriptionsBloc, SubscriptionState>(
      builder: (context, state) {
        final isRestoring = state.status == SubscriptionStatus.restoring;
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.32),
            ),
          ),
          child: TextButton(
            onPressed: isRestoring
                ? null
                : () =>
                      context.read<SubscriptionsBloc>().add(RestorePurchases()),
            child: isRestoring
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  )
                : Text(
                    'Restore Purchases',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: cs.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
