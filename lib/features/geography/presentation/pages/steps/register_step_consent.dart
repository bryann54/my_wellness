import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';

class RegisterStepConsent extends StatefulWidget {
  final bool initialConsent;
  final void Function(bool consent) onSubmit;

  const RegisterStepConsent({
    super.key,
    this.initialConsent = false,
    required this.onSubmit,
  });

  @override
  State<RegisterStepConsent> createState() => _RegisterStepConsentState();
}

class _RegisterStepConsentState extends State<RegisterStepConsent> {
  late bool _consent;

  @override
  void initState() {
    super.initState();
    _consent = widget.initialConsent;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.getString(context, 'auth.reviewAndConfirm'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _consent,
            onChanged: (v) => setState(() => _consent = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              AppLocalizations.getString(context, 'auth.consentHealthData'),
            ),
          ),
          const SizedBox(height: 16),
          AppPrimaryButton(
            onPressed: _consent ? () => widget.onSubmit(_consent) : null,
            label: AppLocalizations.getString(context, 'auth.createAccount'),
          ),
        ],
      ),
    );
  }
}
