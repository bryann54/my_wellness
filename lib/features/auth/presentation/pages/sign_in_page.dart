import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/constatnts/routes.dart';
import 'package:my_wellness/common/widgets/app_button.dart';
import 'package:my_wellness/common/widgets/app_text_field.dart';
import 'package:my_wellness/features/auth/presentation/widgets/auth_bottom_bar.dart';
import 'package:my_wellness/features/auth/presentation/widgets/auth_divider.dart';
import 'package:my_wellness/features/auth/presentation/widgets/auth_header.dart';
import 'package:my_wellness/features/auth/presentation/widgets/google_auth_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isPasswordVisible = false;
  bool _canLogin = false;

  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();
    _email.addListener(_checkFormValidity);
    _password.addListener(_checkFormValidity);
  }

  @override
  void dispose() {
    _email
      ..removeListener(_checkFormValidity)
      ..dispose();
    _password
      ..removeListener(_checkFormValidity)
      ..dispose();
    super.dispose();
  }

  void _checkFormValidity() {
    final ok = _email.text.isNotEmpty &&
        _password.text.isNotEmpty &&
        _emailRegex.hasMatch(_email.text);
    if (ok != _canLogin) setState(() => _canLogin = ok);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AuthHeader(
                    title: 'Welcome Back!',
                    subtitle: 'Log in to continue',
                  ),
                  const SizedBox(height: 40),
                  AppTextField.single(
                    label: 'Email',
                    controller: _email,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Email is required';
                      return _emailRegex.hasMatch(value!)
                          ? null
                          : 'Enter a valid email';
                    },
                    onChanged: (_) => _checkFormValidity(),
                  )
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  AppTextField.single(
                    label: 'Password',
                    controller: _password,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    onVisibilityToggle: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Password is required';
                      }
                      return null;
                    },
                    onChanged: (_) => _checkFormValidity(),
                  )
                      .animate(delay: 500.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: password reset
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ).animate(delay: 600.ms).fadeIn(duration: 600.ms),
                  const SizedBox(height: 32),
                  AppButton(
                    label: 'Log In',
                    onTap: _canLogin
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              // TODO: dispatch sign-in
                            }
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const AuthDivider(text: 'Or log in with'),
                  GoogleAuthButton(
                    text: 'Sign in with Google',
                    onPressed: () {
                      // TODO: Google sign-in
                    },
                  ).animate(delay: 900.ms).fadeIn(duration: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AuthBottomBar(
        promptText: "Don't have an account?",
        actionText: 'Create Account',
        onActionPressed: () {
          Navigator.of(context).pushReplacementNamed(AppRoutes.register);
        },
        heroTag: 'auth_toggle_button',
      ),
    );
  }
}
