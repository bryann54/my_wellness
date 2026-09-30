import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/biometrics/biometrics_bloc.dart';
import 'package:my_wellness/features/auth/presentation/widgets/splash/splash_biometric_prompt.dart';
import 'package:my_wellness/features/auth/presentation/widgets/splash/splash_pin_unlock.dart';

class SplashFailureSheet extends StatelessWidget {
  const SplashFailureSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<BiometricsBloc, BiometricsState>(
      listenWhen: (prev, curr) => prev.isAuthenticated != curr.isAuthenticated,
      listener: (context, state) {
        if (state.isAuthenticated) Navigator.of(context).pop();
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: state.status == BiometricsStatus.pinFallback
                    ? const SplashPinUnlock(key: ValueKey('pin'))
                    : SplashBiometricPrompt(
                        key: const ValueKey('bio'),
                        state: state,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
