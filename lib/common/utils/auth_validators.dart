// lib/common/utils/auth_validators.dart

import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/l10n.dart';

class AuthValidators {
  AuthValidators._();

  // ─────────────────────────────────────────────────────────────────────────
  // Context-free predicates (used by conversational flow and other callers
  // that don't have a BuildContext).
  // ─────────────────────────────────────────────────────────────────────────
  static bool isValidEmail(String value) {
    final t = value.trim();
    if (t.isEmpty || t.length > 254 || t.contains('..')) return false;

    final re = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    if (!re.hasMatch(t)) return false;

    final parts = t.split('@');
    if (parts.length != 2) return false;

    final domainParts = parts[1].split('.');
    if (domainParts.any((p) => p.isEmpty)) return false;
    if (domainParts.last.length < 2) return false;

    return true;
  }

  static bool isValidPhone(String value) {
    final digits = value.trim().replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (!RegExp(r'^[0-9]+$').hasMatch(digits)) return false;
    return digits.length >= 10 && digits.length <= 15;
  }

  static bool isValidName(String value) {
    final t = value.trim();
    if (t.length < 2 || t.length > 60) return false;
    return RegExp(r"^[a-zA-Z\s'\-]+$").hasMatch(t);
  }

  /// Accepts ISO `yyyy-MM-dd`. Rejects malformed dates, future dates, and
  /// ages above 120 years.
  static bool isValidDobIso(String value) {
    final t = value.trim();
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(t);
    if (m == null) return false;

    final y = int.parse(m.group(1)!);
    final mo = int.parse(m.group(2)!);
    final d = int.parse(m.group(3)!);

    final dt = DateTime(y, mo, d);
    if (dt.year != y || dt.month != mo || dt.day != d) return false;
    if (dt.isAfter(DateTime.now())) return false;
    if (DateTime.now().year - y > 120) return false;

    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Email
  // ─────────────────────────────────────────────────────────────────────────
  static String? validateEmail(
    BuildContext context,
    String? value, {
    bool isRequired = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return isRequired
          ? AppLocalizations.getString(context, 'auth.emailRequired')
          : null;
    }
    return isValidEmail(value)
        ? null
        : AppLocalizations.getString(context, 'auth.invalidEmail');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Identifier (email OR phone)
  // ─────────────────────────────────────────────────────────────────────────
  static String? validateIdentifier(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.getString(context, 'auth.identifierRequired');
    }

    final trimmed = value.trim();
    if (trimmed.contains('@')) {
      return validateEmail(context, trimmed);
    }
    return validatePhone(context, trimmed);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Password
  // ─────────────────────────────────────────────────────────────────────────
  static String? validatePassword(
    BuildContext context,
    String? value, {
    bool isStrict = true,
  }) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.getString(context, 'auth.passwordRequired');
    }
    if (value.length < 8) {
      return AppLocalizations.getString(context, 'auth.passwordTooShort');
    }
    if (value.length > 128) {
      return AppLocalizations.getString(context, 'auth.passwordTooLong');
    }

    if (!isStrict) return null;

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return AppLocalizations.getString(
        context,
        'auth.passwordRequiresUppercase',
      );
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return AppLocalizations.getString(
        context,
        'auth.passwordRequiresLowercase',
      );
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return AppLocalizations.getString(context, 'auth.passwordRequiresNumber');
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return AppLocalizations.getString(
        context,
        'auth.passwordRequiresSpecial',
      );
    }

    const commonPasswords = [
      'password',
      '12345678',
      'qwerty',
      'abc123',
      'password123',
      'admin123',
    ];
    if (commonPasswords.contains(value.toLowerCase())) {
      return AppLocalizations.getString(context, 'auth.passwordCommon');
    }
    if (_hasSequentialChars(value)) {
      return AppLocalizations.getString(context, 'auth.passwordSequential');
    }

    return null;
  }

  static String? validateConfirmPassword(
    BuildContext context,
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.getString(
        context,
        'auth.confirmPasswordRequired',
      );
    }
    if (value != originalPassword) {
      return AppLocalizations.getString(context, 'auth.passwordsDontMatch');
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Phone
  // ─────────────────────────────────────────────────────────────────────────
  static String? validatePhone(
    BuildContext context,
    String? value, {
    bool isRequired = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return isRequired
          ? AppLocalizations.getString(context, 'auth.phoneRequired')
          : null;
    }

    final digitsOnly = value.trim().replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (!RegExp(r'^[0-9]+$').hasMatch(digitsOnly)) {
      return AppLocalizations.getString(context, 'auth.phoneInvalidCharacters');
    }
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return AppLocalizations.getString(context, 'auth.phoneInvalidLength');
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Names
  // ─────────────────────────────────────────────────────────────────────────
  static String? validateName(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.getString(context, 'auth.nameRequired');
    }
    if (value.trim().length < 2) {
      return AppLocalizations.getString(context, 'auth.nameTooShort');
    }
    if (value.trim().length > 60) {
      return AppLocalizations.getString(context, 'auth.nameTooLong');
    }
    if (!RegExp(r"^[a-zA-Z\s'\-]+$").hasMatch(value.trim())) {
      return AppLocalizations.getString(context, 'auth.nameInvalidCharacters');
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // National ID (optional)
  // ─────────────────────────────────────────────────────────────────────────
  static String? validateNationalId(
    BuildContext context,
    String? value, {
    bool isRequired = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return isRequired
          ? AppLocalizations.getString(context, 'auth.nationalIdRequired')
          : null;
    }
    final trimmed = value.trim();
    if (!RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(trimmed)) {
      return AppLocalizations.getString(context, 'auth.nationalIdInvalid');
    }
    if (trimmed.length < 4 || trimmed.length > 20) {
      return AppLocalizations.getString(
        context,
        'auth.nationalIdInvalidLength',
      );
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Generic required
  // ─────────────────────────────────────────────────────────────────────────
  static String? validateRequired(
    BuildContext context,
    String? value,
    String fieldName,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Password strength
  // ─────────────────────────────────────────────────────────────────────────
  static int calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength > 4 ? 4 : strength;
  }

  static String getPasswordStrengthText(BuildContext context, int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppLocalizations.getString(context, 'common.weak');
      case 2:
        return AppLocalizations.getString(context, 'common.fair');
      case 3:
        return AppLocalizations.getString(context, 'common.good');
      case 4:
        return AppLocalizations.getString(context, 'common.strong');
      default:
        return AppLocalizations.getString(context, 'common.weak');
    }
  }

  static Color getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return const Color(0xFF3B82F6);
      case 4:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFFEF4444);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────
  static bool _hasSequentialChars(String password) {
    const sequences = [
      '0123456789',
      'abcdefghijklmnopqrstuvwxyz',
      'qwertyuiop',
      'asdfghjkl',
      'zxcvbnm',
    ];

    final lower = password.toLowerCase();
    for (final seq in sequences) {
      for (int i = 0; i <= seq.length - 4; i++) {
        final sub = seq.substring(i, i + 4);
        if (lower.contains(sub)) return true;
        if (lower.contains(sub.split('').reversed.join())) return true;
      }
    }
    return false;
  }
}
