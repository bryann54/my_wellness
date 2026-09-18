// lib/features/auth/presentation/widgets/conversation/conversation_models.dart

import 'package:my_wellness/common/utils/auth_validators.dart';

enum FieldType {
  text,
  email,
  phone,
  password,
  gender, // single-select from a fixed list
  date, // date picker
}

class ConversationStep {
  final String questionKey;
  final FieldType type;

  /// Optional custom validator. Return `null` for valid, otherwise an error.
  final String? Function(String)? validate;

  /// Required when [type] == FieldType.gender.
  /// Each entry is `(apiValue, displayLabel)`.
  final List<ConversationChoice>? choices;

  const ConversationStep({
    required this.questionKey,
    required this.type,
    this.validate,
    this.choices,
  }) : assert(
         type != FieldType.gender || choices != null,
         'gender steps must define choices',
       );
}

class ConversationChoice {
  final String value; // what we send to the API ('male' | 'female' | 'other')
  final String label; // what we show in the bubble/picker
  const ConversationChoice(this.value, this.label);
}

class ConversationMessage {
  final String text;
  final bool isAi;
  ConversationMessage({required this.text, required this.isAi});
}

// ─────────────────────────────────────────────────────────────────────────────
// Signup conversation flow — matches My Wellness Health's signup payload.
// ─────────────────────────────────────────────────────────────────────────────
final List<ConversationStep> conversationSteps = [
  ConversationStep(
    questionKey: 'auth.askFirstName',
    type: FieldType.text,
    validate: (v) =>
        AuthValidators.isValidName(v) ? null : 'Enter a valid first name',
  ),
  ConversationStep(
    questionKey: 'auth.askSurname',
    type: FieldType.text,
    validate: (v) =>
        AuthValidators.isValidName(v) ? null : 'Enter a valid surname',
  ),
  ConversationStep(
    questionKey: 'auth.askEmail',
    type: FieldType.email,
    validate: (v) =>
        AuthValidators.isValidEmail(v) ? null : 'Enter a valid email',
  ),
  ConversationStep(
    questionKey: 'auth.askPhone',
    type: FieldType.phone,
    validate: (v) =>
        AuthValidators.isValidPhone(v) ? null : 'Enter a valid phone number',
  ),
  ConversationStep(
    questionKey: 'auth.askGender',
    type: FieldType.gender,
    choices: const [
      ConversationChoice('male', 'Male'),
      ConversationChoice('female', 'Female'),
      ConversationChoice('other', 'Other'),
    ],
  ),
  ConversationStep(
    questionKey: 'auth.askDob',
    type: FieldType.date,
    validate: (v) => AuthValidators.isValidDobIso(v)
        ? null
        : 'Enter a valid date (yyyy-MM-dd)',
  ),
  ConversationStep(
    questionKey: 'auth.askPassword',
    type: FieldType.password,
    validate: (v) {
      if (v.length < 8) return 'Password must be at least 8 characters';
      if (!v.contains(RegExp(r'[A-Z]'))) return 'Add an uppercase letter';
      if (!v.contains(RegExp(r'[a-z]'))) return 'Add a lowercase letter';
      if (!v.contains(RegExp(r'[0-9]'))) return 'Add a number';
      if (!v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return 'Add a special character';
      }
      return null;
    },
  ),
];
