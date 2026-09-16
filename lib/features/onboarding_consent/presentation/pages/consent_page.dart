import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/features/onboarding_consent/presentation/bloc/consent_bloc.dart';

class ConsentPage extends StatelessWidget {
  const ConsentPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ConsentBloc(),
        child: Scaffold(
          appBar: AppBar(title: const Text('Consent and privacy')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<ConsentBloc, ConsentState>(
                builder: (context, state) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                            'Your consent is required before health information is collected.'),
                        const SizedBox(height: 16),
                        const Text(
                            'The approved policy version, purposes, recording, withdrawal, and retention terms have not yet been supplied to this app.'),
                        const Spacer(),
                        FilledButton(
                          onPressed: () => context
                              .read<ConsentBloc>()
                              .add(const ConsentAcknowledged()),
                          child: const Text('Review consent when available'),
                        ),
                        if (state is ConsentContractUnavailable)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                                'Consent cannot be captured or stored until the approved contract is available.'),
                          ),
                      ],
                    )),
          ),
        ),
      );
}
