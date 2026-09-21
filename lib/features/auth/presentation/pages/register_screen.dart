// lib/features/auth/presentation/pages/register_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/auth_controllers_manager.dart';
import 'package:my_wellness/common/utils/auth_validators.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/widgets/auth_state_listener.dart';
import 'package:my_wellness/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_bottom_bar.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_button.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_header.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_text_field.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final RegisterControllersManager _manager;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _manager = RegisterControllersManager(onFormChanged: () => setState(() {}));
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_manager.validate()) return;

    final request = SignupRequestModel(
      email: _manager.email.trim().isEmpty ? null : _manager.email.trim(),
      phone: _manager.phone.trim().isEmpty ? null : _manager.phone.trim(),
      password: _manager.password,
      firstName: _manager.firstName.trim(),
      surname: _manager.surname.trim(),
      gender: _manager.gender, // 'male' | 'female' | 'other' | null
      dateOfBirth: _manager.dateOfBirth == null
          ? null
          : _isoDate(_manager.dateOfBirth!),
      nationalIdNumber: _manager.nationalIdNumber.trim().isEmpty
          ? null
          : _manager.nationalIdNumber.trim(),
    );

    context.read<AuthBloc>().add(SignUpEvent(request));
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _manager.dateOfBirth ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked != null) _manager.setDateOfBirth(picked);
  }

  @override
  Widget build(BuildContext context) {
    final strength = AuthValidators.calculatePasswordStrength(
      _manager.password,
    );

    return Scaffold(
      body: AuthStateListener(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _manager.formKey,
              autovalidateMode: _manager.showErrors
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthHeader(
                    title: AppLocalizations.getString(
                      context,
                      'auth.createAccount',
                    ),
                    subtitle: AppLocalizations.getString(
                      context,
                      'auth.setupAccount',
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── Email ─────────────────────────────────────────────────
                  AuthTextField(
                    controller: _manager.emailController,
                    label: AppLocalizations.getString(context, 'auth.email'),
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => AuthValidators.validateEmail(context, v),
                  ).animate().fadeIn().slideX(begin: 0.1, end: 0),
                  const SizedBox(height: 16),

                  // ── Phone ─────────────────────────────────────────────────
                  AuthTextField(
                    controller: _manager.phoneController,
                    label: AppLocalizations.getString(
                      context,
                      'auth.phoneNumber',
                    ),
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => AuthValidators.validatePhone(context, v),
                  ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.1, end: 0),
                  const SizedBox(height: 16),

                  // ── First name ────────────────────────────────────────────
                  AuthTextField(
                    controller: _manager.firstNameController,
                    label: AppLocalizations.getString(
                      context,
                      'auth.firstName',
                    ),
                    icon: Icons.badge_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ).animate(delay: 150.ms).fadeIn().slideX(begin: 0.1, end: 0),
                  const SizedBox(height: 16),

                  // ── Surname ───────────────────────────────────────────────
                  AuthTextField(
                    controller: _manager.surnameController,
                    label: AppLocalizations.getString(context, 'auth.surname'),
                    icon: Icons.badge_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.1, end: 0),
                  const SizedBox(height: 16),

                  // ── Gender ────────────────────────────────────────────────
                  DropdownButtonFormField<String>(
                    initialValue: _manager.gender,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.getString(
                        context,
                        'auth.gender',
                      ),
                      prefixIcon: const Icon(Icons.wc_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) => _manager.setGender(v),
                  ).animate(delay: 250.ms).fadeIn().slideX(begin: 0.1, end: 0),
                  const SizedBox(height: 16),

                  // ── Date of birth ─────────────────────────────────────────
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.getString(
                          context,
                          'auth.dateOfBirth',
                        ),
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _manager.dateOfBirth == null
                            ? 'Select date'
                            : _isoDate(_manager.dateOfBirth!),
                      ),
                    ),
                  ).animate(delay: 300.ms).fadeIn().slideX(begin: 0.1, end: 0),
                  const SizedBox(height: 16),

                  // ── National ID ───────────────────────────────────────────
                  AuthTextField(
                    controller: _manager.nationalIdController,
                    label: AppLocalizations.getString(
                      context,
                      'auth.nationalIdNumber',
                    ),
                    icon: Icons.credit_card_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) => null, // optional
                  ).animate(delay: 350.ms).fadeIn().slideX(begin: 0.1, end: 0),
                  const SizedBox(height: 16),

                  // ── Password ──────────────────────────────────────────────
                  AuthTextField(
                    controller: _manager.passwordController,
                    label: AppLocalizations.getString(context, 'auth.password'),
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    onVisibilityToggle: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                    validator: (v) => AuthValidators.validatePassword(
                      context,
                      v,
                      isStrict: true,
                    ),
                  ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.1, end: 0),
                  if (_manager.password.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: PasswordStrengthIndicator(strength: strength),
                    ).animate().fadeIn(),
                  const SizedBox(height: 16),

                  // ── Confirm password ──────────────────────────────────────
                  AuthTextField(
                    controller: _manager.confirmPasswordController,
                    label: AppLocalizations.getString(
                      context,
                      'auth.confirmPassword',
                    ),
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: _isConfirmPasswordVisible,
                    onVisibilityToggle: () => setState(
                      () => _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible,
                    ),
                    validator: (v) => AuthValidators.validateConfirmPassword(
                      context,
                      v,
                      _manager.password,
                    ),
                  ).animate(delay: 450.ms).fadeIn().slideX(begin: 0.1, end: 0),

                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isReady =
                          _manager.canAttemptRegister &&
                          _manager.passwordsMatch &&
                          state.status != AuthStatus.loading;

                      return AuthButton(
                        text: AppLocalizations.getString(
                          context,
                          'auth.createAccount',
                        ),
                        isEnabled: isReady,
                        isLoading: state.status == AuthStatus.loading,
                        onPressed: _handleRegister,
                        heroTag: 'register_button',
                      );
                    },
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GestureDetector(
                          onTap: () => context.router.push(
                            ConversationalRegisterRoute(),
                          ),
                          child: Text(
                            AppLocalizations.getString(
                              context,
                              'auth.preferAi',
                            ),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AuthBottomBar(
        promptText: AppLocalizations.getString(
          context,
          'auth.alreadyHaveAccount',
        ),
        actionText: AppLocalizations.getString(context, 'auth.signInLink'),
        onActionPressed: () => context.router.push(const LoginRoute()),
        heroTag: 'auth_toggle_button',
      ),
    );
  }
}
