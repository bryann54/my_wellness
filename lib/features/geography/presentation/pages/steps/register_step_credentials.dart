import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/auth_validators.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_text_field.dart';

typedef CredentialsCallback =
    void Function({
      required String email,
      required String phone,
      required String password,
    });

class RegisterStepCredentials extends StatefulWidget {
  final String? initialEmail;
  final String? initialPhone;
  final CredentialsCallback onContinue;

  const RegisterStepCredentials({
    super.key,
    this.initialEmail,
    this.initialPhone,
    required this.onContinue,
  });

  @override
  State<RegisterStepCredentials> createState() =>
      _RegisterStepCredentialsState();
}

class _RegisterStepCredentialsState extends State<RegisterStepCredentials> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _confirmCtrl;

  bool _passwordVisible = false;
  bool _confirmVisible = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail ?? '');
    _phoneCtrl = TextEditingController(text: widget.initialPhone ?? '');
    _passwordCtrl = TextEditingController();
    _confirmCtrl = TextEditingController();

    for (final c in [_emailCtrl, _phoneCtrl, _passwordCtrl, _confirmCtrl]) {
      c.addListener(_recheck);
    }
    _recheck();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _recheck() {
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    final emailOk = email.isNotEmpty && AuthValidators.isValidEmail(email);
    final phoneOk = phone.isEmpty || AuthValidators.isValidPhone(phone);
    final passwordOk = AuthValidators.isValidPassword(_passwordCtrl.text);
    final matchOk =
        _confirmCtrl.text.isNotEmpty && _confirmCtrl.text == _passwordCtrl.text;

    final ok = emailOk && phoneOk && passwordOk && matchOk;
    if (ok != _isValid) setState(() => _isValid = ok);
  }

  void _continue() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onContinue(
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.getString(context, 'auth.stepCredentialsHint'),
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _emailCtrl,
              label: AppLocalizations.getString(context, 'auth.email'),
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  AuthValidators.validateEmail(context, v, isRequired: true),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _phoneCtrl,
              label: AppLocalizations.getString(context, 'auth.phoneNumber'),
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  AuthValidators.validatePhone(context, v, isRequired: false),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordCtrl,
              label: AppLocalizations.getString(context, 'auth.password'),
              icon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: _passwordVisible,
              onVisibilityToggle: () =>
                  setState(() => _passwordVisible = !_passwordVisible),
              validator: (v) =>
                  AuthValidators.validatePassword(context, v, isStrict: true),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _confirmCtrl,
              label: AppLocalizations.getString(
                context,
                'auth.confirmPassword',
              ),
              icon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: _confirmVisible,
              onVisibilityToggle: () =>
                  setState(() => _confirmVisible = !_confirmVisible),
              validator: (v) => AuthValidators.validateConfirmPassword(
                context,
                v,
                _passwordCtrl.text,
              ),
            ),
            const SizedBox(height: 32),
            AppPrimaryButton(
              onPressed: _isValid ? _continue : null,
              label: AppLocalizations.getString(context, 'common.continue'),
              borderRadius: 12,
              height: 52,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
