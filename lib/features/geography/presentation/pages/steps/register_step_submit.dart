import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';

class SubmitSummary {
  final String? email;
  final String? phone;
  final String firstName;
  final String surname;
  final String? gender;
  final DateTime? dateOfBirth;
  final County? county;
  final SubCounty? subCounty;

  const SubmitSummary({
    this.email,
    this.phone,
    required this.firstName,
    required this.surname,
    this.gender,
    this.dateOfBirth,
    this.county,
    this.subCounty,
  });
}

class RegisterStepSubmit extends StatelessWidget {
  final SubmitSummary summary;
  final bool isLoading;
  final VoidCallback? onSubmit;

  const RegisterStepSubmit({
    super.key,
    required this.summary,
    this.isLoading = false,
    this.onSubmit,
  });

  static String _isoDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.getString(context, 'auth.reviewDetails'),
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: cs.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 20),
          _Section(
            title: AppLocalizations.getString(context, 'auth.contactSection'),
            rows: [
              if (summary.email != null && summary.email!.isNotEmpty)
                _Row(
                  label: AppLocalizations.getString(context, 'auth.email'),
                  value: summary.email!,
                ),
              if (summary.phone != null && summary.phone!.isNotEmpty)
                _Row(
                  label: AppLocalizations.getString(
                    context,
                    'auth.phoneNumber',
                  ),
                  value: summary.phone!,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: AppLocalizations.getString(context, 'auth.identitySection'),
            rows: [
              _Row(
                label: AppLocalizations.getString(context, 'common.name'),
                value: '${summary.firstName} ${summary.surname}'.trim(),
              ),
              if (summary.gender != null)
                _Row(
                  label: AppLocalizations.getString(context, 'auth.gender'),
                  value: summary.gender == 'female'
                      ? AppLocalizations.getString(context, 'auth.genderFemale')
                      : AppLocalizations.getString(context, 'auth.genderMale'),
                ),
              if (summary.dateOfBirth != null)
                _Row(
                  label: AppLocalizations.getString(
                    context,
                    'auth.dateOfBirth',
                  ),
                  value: _isoDate(summary.dateOfBirth!),
                ),
            ],
          ),
          if (summary.county != null || summary.subCounty != null) ...[
            const SizedBox(height: 16),
            _Section(
              title: AppLocalizations.getString(
                context,
                'auth.locationSection',
              ),
              rows: [
                if (summary.county != null)
                  _Row(
                    label: AppLocalizations.getString(context, 'auth.county'),
                    value: summary.county!.name,
                  ),
                if (summary.subCounty != null)
                  _Row(
                    label: AppLocalizations.getString(
                      context,
                      'auth.subCounty',
                    ),
                    value: summary.subCounty!.name,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          AppPrimaryButton(
            onPressed: isLoading ? null : onSubmit,
            label: AppLocalizations.getString(context, 'auth.createAccount'),
            isLoading: isLoading,
            borderRadius: 12,
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _Section({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
