import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/pricing/domain/entities/payment_destination.dart';
import 'package:my_wellness/features/pricing/presentation/bloc/pricing_bloc.dart';

@RoutePage()
class PaymentOutcomeScreen extends StatelessWidget {
  final PricingDestination? initialDestination;
  final void Function(PricingDestination destination)? onNavigate;

  const PaymentOutcomeScreen({
    super.key,
    this.initialDestination,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<PricingBloc>(),
      child: _PaymentOutcomeBody(
        initialDestination: initialDestination,
        onNavigate: onNavigate,
      ),
    );
  }
}

class _PaymentOutcomeBody extends StatefulWidget {
  final PricingDestination? initialDestination;
  final void Function(PricingDestination destination)? onNavigate;

  const _PaymentOutcomeBody({this.initialDestination, this.onNavigate});

  @override
  State<_PaymentOutcomeBody> createState() => _PaymentOutcomeBodyState();
}

class _PaymentOutcomeBodyState extends State<_PaymentOutcomeBody> {
  bool _navigated = false;

  @override
  void dispose() {
    context.read<PricingBloc>().add(const CancelPollingEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.read<PricingBloc>().add(const CancelPollingEvent());
        context.router.maybePop();
      },
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            CustomAppBar(
              title: AppLocalizations.getString(
                context,
                'pricing.outcome.title',
              ),
              isHome: false,
            ),
          ],
          body: BlocConsumer<PricingBloc, PricingState>(
            listenWhen: (p, c) =>
                p.paymentPollStatus != c.paymentPollStatus ||
                p.accessReady != c.accessReady,
            listener: (context, state) {
              if (_navigated) return;
              if (state.paymentPollStatus == PaymentPollStatus.success &&
                  state.accessReady) {
                _navigated = true;
                Future.delayed(const Duration(milliseconds: 1900), () {
                  if (!mounted) return;
                  final dest =
                      state.destination?.destination ??
                      widget.initialDestination ??
                      PricingDestination.dashboard;
                  widget.onNavigate?.call(dest);
                  context.router.maybePop();
                });
              }
            },
            builder: (context, state) {
              switch (state.paymentPollStatus) {
                case PaymentPollStatus.notStarted:
                  return const _WaitingView(label: 'Preparing your payment…');
                case PaymentPollStatus.waiting:
                  return _WaitingView(
                    label: AppLocalizations.getString(
                      context,
                      'pricing.outcome.waiting',
                    ),
                  );
                case PaymentPollStatus.waitingTooLong:
                  return _WaitingView(
                    label: AppLocalizations.getString(
                      context,
                      'pricing.outcome.stillWaiting',
                    ),
                  );
                case PaymentPollStatus.success:
                  return _SuccessView(amountKes: state.payment?.amountKes ?? 0);
                case PaymentPollStatus.failed:
                  return const _FailedView();
              }
            },
          ),
        ),
      ),
    );
  }
}

class _WaitingView extends StatelessWidget {
  final String label;
  const _WaitingView({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(height: 20),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.5,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.getString(context, 'pricing.outcome.hint'),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final int amountKes;
  const _SuccessView({required this.amountKes});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 56, color: cs.primary),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.getString(context, 'pricing.outcome.successTitle'),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.getString(context, 'pricing.outcome.successBody'),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              height: 1.5,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.getString(context, 'pricing.outcome.opening'),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: cs.primary),
          ),
        ],
      ),
    );
  }
}

class _FailedView extends StatelessWidget {
  const _FailedView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Icon(Icons.error_outline, size: 56, color: cs.error),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.getString(
                context,
                'pricing.outcome.failedTitle',
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.getString(context, 'pricing.outcome.failedBody'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                height: 1.5,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              onPressed: () => context.router.maybePop(),
              label: AppLocalizations.getString(
                context,
                'pricing.outcome.tryAgain',
              ),
              height: 52,
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.getString(
                      context,
                      'pricing.outcome.paybillHeading',
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PaybillRow(
                    label: AppLocalizations.getString(
                      context,
                      'pricing.outcome.businessNumber',
                    ),
                    value: '522533',
                  ),
                  const SizedBox(height: 6),
                  _PaybillRow(
                    label: AppLocalizations.getString(
                      context,
                      'pricing.outcome.accountNumber',
                    ),
                    value: '8097136',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.getString(
                      context,
                      'pricing.outcome.paybillNote',
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      height: 1.45,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.router.maybePop(),
              child: Text(
                AppLocalizations.getString(context, 'pricing.outcome.back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaybillRow extends StatelessWidget {
  final String label;
  final String value;
  const _PaybillRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
          },
          child: Icon(Icons.copy_outlined, size: 16, color: cs.primary),
        ),
      ],
    );
  }
}
