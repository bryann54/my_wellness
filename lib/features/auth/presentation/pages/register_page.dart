import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_wellness/common/constatnts/routes.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/widgets/app_button.dart';
import 'package:my_wellness/common/widgets/app_text_field.dart';
import 'package:my_wellness/features/auth/presentation/widgets/auth_bottom_bar.dart';
import 'package:my_wellness/features/auth/presentation/widgets/auth_header.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const _totalSteps = 4;
  int _step = 1;

  // Step 1 — your details
  final _firstName = TextEditingController();
  final _surname = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  // Step 2 — about you
  String? _gender;
  DateTime? _dob;
  final _dobDisplay = TextEditingController();
  final _nationalId = TextEditingController();

  // Step 3 — security
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _firstName,
      _surname,
      _email,
      _phone,
      _nationalId,
      _password,
      _confirm,
    ]) {
      c.addListener(_validate);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _firstName,
      _surname,
      _email,
      _phone,
      _dobDisplay,
      _nationalId,
      _password,
      _confirm,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _validate() {
    bool ok;
    switch (_step) {
      case 1:
        ok = _firstName.text.isNotEmpty &&
            _surname.text.isNotEmpty &&
            (_email.text.isNotEmpty || _phone.text.isNotEmpty);
        break;
      case 2:
        ok = _gender != null && _dob != null;
        break;
      case 3:
        ok = _password.text.length >= 6 && _password.text == _confirm.text;
        break;
      default:
        ok = true;
    }
    if (ok != _canContinue) setState(() => _canContinue = ok);
  }

  void _next() {
    if (_step < _totalSteps) {
      setState(() {
        _step++;
        _canContinue = false;
      });
      _validate();
      return;
    }
    // TODO: submit to auth
    Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
  }

  void _back() {
    if (_step > 1) {
      setState(() {
        _step--;
        _canContinue = false;
      });
      _validate();
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1995),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _dob = picked;
      _dobDisplay.text = '${picked.day}/${picked.month}/${picked.year}';
    });
    _validate();
  }

  String get _stepSubtitle {
    switch (_step) {
      case 1:
        return 'Your details';
      case 2:
        return 'About you';
      case 3:
        return 'Secure your account';
      default:
        return 'Almost done';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(
                title: 'Create Account',
                subtitle: _stepSubtitle,
              ),
              const SizedBox(height: 8),
              _StepIndicator(current: _step, total: _totalSteps),
              // const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Column(
                  key: ValueKey(_step),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildStep(),
                ),
              ),
              const SizedBox(height: 32),
              _buildFooter(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AuthBottomBar(
        promptText: 'Already have an account?',
        actionText: 'Sign In',
        onActionPressed: () {
          Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
        },
        heroTag: 'auth_toggle_button',
      ),
    );
  }

  List<Widget> _buildStep() {
    switch (_step) {
      case 1:
        return [
          Text(
            'Provide your email, phone number, or both — at least one is required.',
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: 'Name',
            fields: [
              AppFieldSpec(
                controller: _firstName,
                hint: 'First name',
                onChanged: (_) => _validate(),
              ),
              AppFieldSpec(
                controller: _surname,
                hint: 'Surname',
                onChanged: (_) => _validate(),
              ),
            ],
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          AppTextField.single(
            label: 'Email address',
            controller: _email,
            hint: 'you@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => _validate(),
          )
              .animate(delay: 300.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          AppTextField.single(
            label: 'Phone number',
            controller: _phone,
            hint: '0712 345 678',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            helperText: "Saved as a contact number — verification isn't required alongside an email.",
            onChanged: (_) => _validate(),
          )
              .animate(delay: 400.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
        ];

      case 2:
        return [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _genderChip('Female'),
                        const SizedBox(width: 16),
                        _genderChip('Male'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField.single(
                  label: 'Date of birth',
                  controller: _dobDisplay,
                  hint: 'mm/dd/yyyy',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _pickDob,
                ),
              ),
            ],
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 12),
          Text(
            "Used to auto-fill your gender and age on health assessments, so you're not asked again every time.",
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          AppTextField.single(
            label: 'National ID number',
            controller: _nationalId,
            hint: 'e.g. 12345678',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            helperText:
                'Needed to connect your records with hospitals and other healthcare systems.',
            onChanged: (_) => _validate(),
          )
              .animate(delay: 300.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
        ];

      case 3:
        return [
          AppTextField.single(
            label: 'Password',
            controller: _password,
            icon: Icons.lock_outline,
            isPassword: true,
            isPasswordVisible: _isPasswordVisible,
            onVisibilityToggle: () => setState(
              () => _isPasswordVisible = !_isPasswordVisible,
            ),
            onChanged: (_) => _validate(),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          AppTextField.single(
            label: 'Confirm Password',
            controller: _confirm,
            icon: Icons.lock_outline,
            isPassword: true,
            isPasswordVisible: _isConfirmVisible,
            onVisibilityToggle: () => setState(
              () => _isConfirmVisible = !_isConfirmVisible,
            ),
            onChanged: (_) => _validate(),
          )
              .animate(delay: 300.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            'Password must be at least 6 characters.',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ];

      default:
        return [
          Text(
            'Review your details and tap "Create Account" to finish.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ];
    }
  }

  Widget _genderChip(String value) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () {
        setState(() => _gender = value);
        _validate();
      },
      child: Row(
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: selected ? Colors.white : Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    if (_step == 1) {
      return AppButton(
        label: 'Continue',
        onTap: _canContinue ? _next : null,
      );
    }
    return Row(
      children: [
        Expanded(child: AppButton(label: 'Back', onTap: _back)),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton(
            label: _step == _totalSteps ? 'Create Account' : 'Continue',
            onTap: _canContinue ? _next : null,
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 5,
            backgroundColor: grey.withValues(alpha: 0.25),
            valueColor: const AlwaysStoppedAnimation(colorPrimary),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Step $current of $total',
          style: TextStyle(
            fontSize: 12.5,
            color: grey.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}
