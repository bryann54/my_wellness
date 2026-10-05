
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/identity/update_identity_sheet.dart';

class VerifiedIdentitySection extends StatelessWidget {
  final HealthProfile profile;
  const VerifiedIdentitySection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
            
              Expanded(
                child: Text(
                  AppLocalizations.getString(
                    context,
                    'profile.verifiedIdentity',
                  ).toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.getString(
              context,
              'profile.verifiedIdentityHelp',
            ),
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.4,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 18),

          _ReadOnlyRow(
            label: AppLocalizations.getString(context, 'profile.fullName'),
            value: profile.fullName,
            cs: cs,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ReadOnlyRow(
                  label: AppLocalizations.getString(context, 'profile.gender'),
                  value: _genderLabel(context, profile.gender),
                  cs: cs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReadOnlyRow(
                  label: AppLocalizations.getString(
                    context,
                    'profile.dateOfBirth',
                  ),
                  value: profile.dateOfBirth ?? '—',
                  cs: cs,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ReadOnlyRow(
            label: AppLocalizations.getString(context, 'profile.nationalId'),
            value: profile.nationalIdNumber ?? '—',
            cs: cs,
          ),

          const SizedBox(height: 18),
      AppPrimaryButton(
        onPressed: () => UpdateIdentitySheet.show(context),
        label: AppLocalizations.getString(context, 'profile.updateIdentity'),
          borderRadius: 12,
            color: AppColors.primaryColor,
      ),
        ],
      ),
    );
  }

  static String _genderLabel(BuildContext context, String raw) {
    if (raw.isEmpty) return '—';
    final key = 'profile.gender.$raw';
    final localized = AppLocalizations.getString(context, key);
    return localized == key ? raw : localized;
  }
}

class _ReadOnlyRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;

  const _ReadOnlyRow({
    required this.label,
    required this.value,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.67),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
