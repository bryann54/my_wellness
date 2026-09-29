import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/auth/presentation/widgets/shared/auth_text_field.dart';

class IdentityDraft {
  final IdType idType;
  final String idNumber;
  final String? verificationId;
  final String firstName;
  final String surname;
  final String? gender;
  final DateTime? dateOfBirth;

  const IdentityDraft({
    required this.idType,
    required this.idNumber,
    this.verificationId,
    this.firstName = '',
    this.surname = '',
    this.gender,
    this.dateOfBirth,
  });

  bool get isVerified => verificationId != null && verificationId!.isNotEmpty;

  IdentityDraft copyWith({
    IdType? idType,
    String? idNumber,
    String? verificationId,
    String? firstName,
    String? surname,
    String? gender,
    DateTime? dateOfBirth,
    bool clearVerification = false,
  }) {
    return IdentityDraft(
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      verificationId: clearVerification
          ? null
          : (verificationId ?? this.verificationId),
      firstName: firstName ?? this.firstName,
      surname: surname ?? this.surname,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}

class RegisterStepIdentity extends StatefulWidget {
  final IdentityDraft? initial;
  final void Function(IdentityDraft) onContinue;

  const RegisterStepIdentity({
    super.key,
    this.initial,
    required this.onContinue,
  });

  @override
  State<RegisterStepIdentity> createState() => _RegisterStepIdentityState();
}

class _RegisterStepIdentityState extends State<RegisterStepIdentity> {
  late final TextEditingController _idCtrl;

  IdType _idType = IdType.nationalId;
  String? _verificationId;
  String _firstName = '';
  String _surname = '';
  String? _gender;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _idType = i.idType;
      _idCtrl = TextEditingController(text: i.idNumber);
      _verificationId = i.verificationId;
      _firstName = i.firstName;
      _surname = i.surname;
      _gender = i.gender;
      _dateOfBirth = i.dateOfBirth;
    } else {
      _idCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  bool get _isVerified =>
      _verificationId != null && _verificationId!.isNotEmpty;
  bool get _canVerify => _idCtrl.text.trim().length >= 6 && !_isVerified;

  void _verify() {
    if (!_canVerify) return;
    context.read<AuthBloc>().add(
      VerifyIdentityEvent(
        idType: _idType == IdType.nationalId ? 'national_id' : 'maisha_card',
        idNumber: _idCtrl.text.trim(),
      ),
    );
  }

  void _useDifferentId() {
    context.read<AuthBloc>().add(const ResetIdentityVerificationEvent());
    setState(() {
      _verificationId = null;
      _firstName = '';
      _surname = '';
      _gender = null;
      _dateOfBirth = null;
      _idCtrl.clear();
    });
  }

  void _continue() {
    if (!_isVerified) return;
    widget.onContinue(
      IdentityDraft(
        idType: _idType,
        idNumber: _idCtrl.text.trim(),
        verificationId: _verificationId,
        firstName: _firstName,
        surname: _surname,
        gender: _gender,
        dateOfBirth: _dateOfBirth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev.kycStatus != curr.kycStatus || prev.kycError != curr.kycError,
      listener: (context, state) {
        if (state.kycStatus == KycStatus.verified &&
            state.verifiedIdentity != null) {
          final v = state.verifiedIdentity!;
          setState(() {
            _verificationId = v.verificationId;
            _firstName = v.firstName;
            _surname = v.lastName;
            _gender = v.gender;
            _dateOfBirth = v.dateOfBirth == null
                ? null
                : DateTime.tryParse(v.dateOfBirth!);
          });
        }
        if (state.kycStatus == KycStatus.error && state.kycError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.kycError!)));
        }
      },
      builder: (context, state) {
        final verifying = state.kycStatus == KycStatus.verifying;
        final verified = _isVerified;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Success banner ─────────────────────────────────────
              if (verified) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.getString(context, 'auth.idVerified'),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── ID type + number (hidden when verified) ────────────
              if (!verified) ...[
                Text(
                  AppLocalizations.getString(context, 'auth.idType'),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _IdTypeOption(
                        label: AppLocalizations.getString(
                          context,
                          'auth.idTypeNational',
                        ),
                        selected: _idType == IdType.nationalId,
                        onTap: () =>
                            setState(() => _idType = IdType.nationalId),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _IdTypeOption(
                        label: AppLocalizations.getString(
                          context,
                          'auth.idTypeMaisha',
                        ),
                        selected: _idType == IdType.maisha,
                        onTap: () => setState(() => _idType = IdType.maisha),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  controller: _idCtrl,
                  keyboardType: TextInputType.number,
                  label: AppLocalizations.getString(context, 'auth.idNumber'),
                  icon: Icons.perm_identity,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                AppPrimaryButton(
                  onPressed: (_canVerify && !verifying) ? _verify : null,
                  label: AppLocalizations.getString(context, 'auth.verifyId'),
                  isLoading: verifying,
                  borderRadius: 12,
                  height: 52,
                  color: AppColors.primaryColor,
                ),
              ],

              // ── Prefilled identity (read-only when verified) ───────
              if (verified) ...[
                _ReadOnlyField(
                  label: AppLocalizations.getString(context, 'auth.firstName'),
                  value: _firstName,
                ),
                const SizedBox(height: 16),
                _ReadOnlyField(
                  label: AppLocalizations.getString(context, 'auth.surname'),
                  value: _surname,
                ),
                const SizedBox(height: 16),
                _ReadOnlyField(
                  label: AppLocalizations.getString(context, 'auth.gender'),
                  value: _gender == null
                      ? ''
                      : (_gender == 'female'
                            ? AppLocalizations.getString(
                                context,
                                'auth.genderFemale',
                              )
                            : AppLocalizations.getString(
                                context,
                                'auth.genderMale',
                              )),
                ),
                const SizedBox(height: 16),
                _ReadOnlyField(
                  label: AppLocalizations.getString(
                    context,
                    'auth.dateOfBirth',
                  ),
                  value: _dateOfBirth == null
                      ? ''
                      : '${_dateOfBirth!.year}-'
                            '${_dateOfBirth!.month.toString().padLeft(2, '0')}-'
                            '${_dateOfBirth!.day.toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.getString(context, 'auth.verifiedIdNotice'),
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    height: 1.5,
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: _useDifferentId,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                  child: Text(
                    AppLocalizations.getString(context, 'auth.useDifferentId'),
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppPrimaryButton(
                  color: AppColors.primaryColor,
                  onPressed: _continue,
                  label: AppLocalizations.getString(context, 'common.continue'),
                  borderRadius: 12,
                  height: 52,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _IdTypeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _IdTypeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.08) : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? cs.primary
                : cs.outlineVariant.withValues(alpha: 0.6),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? cs.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? cs.primary : Colors.grey.shade400,
                  width: 1.6,
                ),
              ),
              child: selected
                  ? const Center(
                      child: Icon(
                        Icons.circle,
                        size: 7,
                        color: AppColors.background,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: cs.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
