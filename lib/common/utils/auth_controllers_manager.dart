// lib/common/utils/auth_controllers_manager.dart

import 'package:flutter/material.dart';

abstract class BaseAuthManager {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final VoidCallback? onFormChanged;

  /// Controls global error visibility.
  bool showErrors = false;

  BaseAuthManager(this.onFormChanged);

  void dispose();

  bool validate() {
    showErrors = true;
    onFormChanged?.call();
    return formKey.currentState?.validate() ?? false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Login
// ─────────────────────────────────────────────────────────────────────────────

class LoginControllersManager extends BaseAuthManager {
  /// Accepts an email *or* a phone number — sent as `identifier` to the API.
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  LoginControllersManager({VoidCallback? onFormChanged})
    : super(onFormChanged) {
    if (onFormChanged != null) {
      identifierController.addListener(onFormChanged);
      passwordController.addListener(onFormChanged);
    }
  }

  String get identifier => identifierController.text.trim();
  String get password => passwordController.text;

  bool get canAttemptLogin => identifier.isNotEmpty && password.isNotEmpty;

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Register
// ─────────────────────────────────────────────────────────────────────────────

class RegisterControllersManager extends BaseAuthManager {
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final firstNameController = TextEditingController();
  final surnameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  /// 'male' | 'female' | 'other'
  String? _gender;

  /// Local Date; converted to ISO yyyy-MM-dd at submit.
  DateTime? _dateOfBirth;

  RegisterControllersManager({VoidCallback? onFormChanged})
    : super(onFormChanged) {
    if (onFormChanged != null) {
      emailController.addListener(onFormChanged);
      phoneController.addListener(onFormChanged);
      firstNameController.addListener(onFormChanged);
      surnameController.addListener(onFormChanged);
      nationalIdController.addListener(onFormChanged);
      passwordController.addListener(onFormChanged);
      confirmPasswordController.addListener(onFormChanged);
    }
  }

  // ── Getters ──────────────────────────────────────────────────────────────
  String get email => emailController.text.trim();
  String get phone => phoneController.text.trim();
  String get firstName => firstNameController.text.trim();
  String get surname => surnameController.text.trim();
  String get nationalIdNumber => nationalIdController.text.trim();
  String get password => passwordController.text;
  String get confirmPassword => confirmPasswordController.text;

  String? get gender => _gender;
  DateTime? get dateOfBirth => _dateOfBirth;

  // ── Setters for non-text fields ──────────────────────────────────────────
  void setGender(String? value) {
    _gender = value;
    onFormChanged?.call();
  }

  void setDateOfBirth(DateTime? value) {
    _dateOfBirth = value;
    onFormChanged?.call();
  }

  // ── Validity ─────────────────────────────────────────────────────────────
  bool get passwordsMatch => password == confirmPassword;

  /// At least one of email/phone is required by the API.
  bool get hasContactMethod => email.isNotEmpty || phone.isNotEmpty;

  bool get canAttemptRegister =>
      hasContactMethod &&
      firstName.isNotEmpty &&
      surname.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      passwordsMatch;

  /// ISO-8601 date string for the API (`date_of_birth`).
  String? get dateOfBirthIso {
    final d = _dateOfBirth;
    if (d == null) return null;
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    firstNameController.dispose();
    surnameController.dispose();
    nationalIdController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Password reset
// ─────────────────────────────────────────────────────────────────────────────

class PasswordResetControllersManager extends BaseAuthManager {
  /// Accepts email or phone — matches the API's `identifier` field.
  final identifierController = TextEditingController();

  PasswordResetControllersManager({VoidCallback? onFormChanged})
    : super(onFormChanged) {
    if (onFormChanged != null) {
      identifierController.addListener(onFormChanged);
    }
  }

  String get identifier => identifierController.text.trim();
  bool get hasIdentifier => identifier.isNotEmpty;

  @override
  void dispose() {
    identifierController.dispose();
  }
}
