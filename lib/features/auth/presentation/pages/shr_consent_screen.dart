import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/core/api_client/client/api_client.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/core/errors/exceptions.dart';

/// Optional post-signup consent step for Kenya's DHA Shared Health Record.
/// The visit is created asynchronously, so this screen mirrors web by polling
/// every three seconds until DHA returns a terminal state.
@RoutePage()
class ShrConsentScreen extends StatefulWidget {
  const ShrConsentScreen({super.key});

  @override
  State<ShrConsentScreen> createState() => _ShrConsentScreenState();
}

class _ShrConsentScreenState extends State<ShrConsentScreen> {
  final _client = getIt<ApiClient>();
  final _otpController = TextEditingController();
  final _reasonController = TextEditingController();
  Timer? _pollTimer;
  Map<String, dynamic>? _visit;
  bool _sending = false;
  bool _declining = false;

  String? get _visitId => _visit?['id']?.toString();
  String? get _status => _visit?['status']?.toString();

  @override
  void initState() {
    super.initState();
    _poll();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _otpController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _poll() async {
    if (_sending || !mounted) return;
    try {
      final visit = await _client.get<Map<String, dynamic>>(
        url: ApiEndpoints.shrVisitMine,
        options: ApiClient.protected,
      );
      if (!mounted) return;
      final status = visit['status']?.toString();
      setState(() => _visit = visit);
      if (status == 'open' || status == 'rejected') {
        _pollTimer?.cancel();
      } else if (status == 'expired' ||
          status == 'closed' ||
          status == 'pending_closure_otp') {
        _pollTimer?.cancel();
        await context.router.maybePop();
      }
    } on NotFoundException {
      // The server is still creating the DHA visit. Keep polling.
    } on Exception {
      // Poll failures are transient and must not block signup.
    }
  }

  Future<void> _verify() async {
    final id = _visitId;
    final otp = _otpController.text.trim();
    if (id == null || otp.length < 4) return;
    await _perform(() async {
      final visit = await _client.post<Map<String, dynamic>>(
        url: ApiEndpoints.shrVisitVerify(id),
        payload: {'otp': otp},
        options: ApiClient.protected,
      );
      if (mounted) setState(() => _visit = visit);
    });
  }

  Future<void> _resend() async {
    final id = _visitId;
    if (id == null) return;
    await _perform(() async {
      final visit = await _client.post<Map<String, dynamic>>(
        url: ApiEndpoints.shrVisitResend(id),
        options: ApiClient.protected,
      );
      if (!mounted) return;
      setState(() => _visit = visit);
      AppSnackbar.success(
        context,
        AppLocalizations.getString(context, 'shr.codeResent'),
      );
    });
  }

  Future<void> _reject() async {
    final id = _visitId;
    if (id == null) return;
    await _perform(() async {
      final visit = await _client.post<Map<String, dynamic>>(
        url: ApiEndpoints.shrVisitReject(id),
        payload: {'rejection_reason': _reasonController.text.trim()},
        options: ApiClient.protected,
      );
      if (mounted) setState(() => _visit = visit);
    });
  }

  Future<void> _perform(Future<void> Function() action) async {
    setState(() => _sending = true);
    try {
      await action();
    } on ValidationException catch (error) {
      if (mounted) AppSnackbar.error(context, error.message);
    } on Exception {
      if (mounted) {
        AppSnackbar.error(
          context,
          AppLocalizations.getString(context, 'shr.dhaError'),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: NestedScrollView(
      headerSliverBuilder: (_, _) => [
        CustomAppBar(
          title: AppLocalizations.getString(context, 'shr.title'),
          isHome: false,
        ),
      ],
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _content(),
          ),
        ),
      ),
    ),
  );

  Widget _content() {
    if (_status == 'open') {
      return _Result(
        key: const ValueKey('open'),
        icon: Icons.verified_rounded,
        title: AppLocalizations.getString(context, 'shr.linkedTitle'),
        body: AppLocalizations.getString(context, 'shr.linkedBody'),
        onDone: () => context.router.maybePop(),
      );
    }
    if (_status == 'rejected') {
      return _Result(
        key: const ValueKey('rejected'),
        icon: Icons.shield_outlined,
        title: AppLocalizations.getString(context, 'shr.declinedTitle'),
        body: AppLocalizations.getString(context, 'shr.declinedBody'),
        onDone: () => context.router.maybePop(),
      );
    }
    if (_visit == null || _status != 'pending_otp') {
      return _Waiting(
        key: const ValueKey('waiting'),
        onSkip: () => context.router.maybePop(),
      );
    }
    if (_declining) {
      return _DeclineForm(
        key: const ValueKey('decline'),
        controller: _reasonController,
        sending: _sending,
        onBack: () => setState(() => _declining = false),
        onConfirm: _reject,
      );
    }
    return _OtpForm(
      key: const ValueKey('otp'),
      controller: _otpController,
      sending: _sending,
      onChanged: () => setState(() {}),
      onConfirm: _verify,
      onResend: _resend,
      onDecline: () => setState(() => _declining = true),
      onSkip: () => context.router.maybePop(),
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({super.key, required this.onSkip});
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 36),
      const CircularProgressIndicator.adaptive(),
      const SizedBox(height: 24),
      Text(
        AppLocalizations.getString(context, 'shr.linking'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 12),
      Text(
        AppLocalizations.getString(context, 'shr.linkingBody'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 28),
      TextButton(
        onPressed: onSkip,
        child: Text(AppLocalizations.getString(context, 'shr.skipForNow')),
      ),
    ],
  );
}

class _OtpForm extends StatelessWidget {
  const _OtpForm({
    super.key,
    required this.controller,
    required this.sending,
    required this.onChanged,
    required this.onConfirm,
    required this.onResend,
    required this.onDecline,
    required this.onSkip,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onChanged;
  final VoidCallback onConfirm;
  final VoidCallback onResend;
  final VoidCallback onDecline;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.getString(context, 'shr.title'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.getString(context, 'shr.otpBody'),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: .45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.primary.withValues(alpha: .28)),
          ),
          child: Text(
            AppLocalizations.getString(context, 'shr.consentBody'),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: controller,
          enabled: !sending,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: AppLocalizations.getString(
              context,
              'shr.verificationCode',
            ),
            hintText: AppLocalizations.getString(context, 'shr.codeHint'),
          ),
        ),
        const SizedBox(height: 20),
        AppPrimaryButton(
          onPressed: controller.text.trim().length >= 4 && !sending
              ? onConfirm
              : null,
          label: AppLocalizations.getString(context, 'common.confirm'),
          isLoading: sending,
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: [
            TextButton(
              onPressed: sending ? null : onResend,
              child: Text(
                AppLocalizations.getString(context, 'auth.resendCode'),
              ),
            ),
            TextButton(
              onPressed: sending ? null : onDecline,
              child: Text(
                AppLocalizations.getString(context, 'shr.decline'),
              ),
            ),
            TextButton(
              onPressed: sending ? null : onSkip,
              child: Text(
                AppLocalizations.getString(context, 'shr.skipForNow'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeclineForm extends StatelessWidget {
  const _DeclineForm({
    super.key,
    required this.controller,
    required this.sending,
    required this.onBack,
    required this.onConfirm,
  });
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        AppLocalizations.getString(context, 'shr.declineTitle'),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 16),
      TextField(
        controller: controller,
        minLines: 3,
        maxLines: 5,
        decoration: InputDecoration(
          labelText: AppLocalizations.getString(
            context,
            'shr.declineReason',
          ),
        ),
      ),
      const SizedBox(height: 20),
      AppPrimaryButton(
        onPressed: sending ? null : onConfirm,
        label: AppLocalizations.getString(context, 'shr.confirmDecline'),
        isLoading: sending,
      ),
      TextButton(
        onPressed: sending ? null : onBack,
        child: Text(AppLocalizations.getString(context, 'common.back')),
      ),
    ],
  );
}

class _Result extends StatelessWidget {
  const _Result({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.onDone,
  });
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 28),
      Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 18),
      Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 10),
      Text(body, textAlign: TextAlign.center),
      const SizedBox(height: 26),
      AppPrimaryButton(
        onPressed: onDone,
        label: AppLocalizations.getString(context, 'shr.done'),
      ),
    ],
  );
}
