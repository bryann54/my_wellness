
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/auth/data/models/signup_request_model.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';

class UpdateIdentitySheet extends StatefulWidget {
  const UpdateIdentitySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AuthBloc>()),
          BlocProvider.value(value: context.read<AccountBloc>()),
        ],
        child: const UpdateIdentitySheet(),
      ),
    );
  }

  @override
  State<UpdateIdentitySheet> createState() => _UpdateIdentitySheetState();
}

class _UpdateIdentitySheetState extends State<UpdateIdentitySheet> {
  IdType _idType = IdType.nationalId;
  final _idCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _idCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _idCtrl.text.trim().length >= 6;

  void _submit() {
    HapticFeedback.lightImpact();
    context.read<AuthBloc>().add(
      VerifyIdentityEvent(
        idType: _idType == IdType.nationalId ? 'national_id' : 'maisha',
        idNumber: _idCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) =>
          p.kycStatus != c.kycStatus || p.kycError != c.kycError,
      listener: (context, state) {
        if (state.kycStatus == KycStatus.verified) {
          Navigator.of(context).pop();
          AppSnackbar.success(
            context,
            AppLocalizations.getString(context, 'profile.identityUpdated'),
          );
          context.read<AccountBloc>().add(const FetchProfileEvent());
        } else if (state.kycStatus == KycStatus.error &&
            state.kycError != null) {
          AppSnackbar.error(context, state.kycError!);
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              AppLocalizations.getString(
                context,
                'profile.updateIdentityTitle',
              ),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.getString(context, 'profile.updateIdentityHelp'),
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.45,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              AppLocalizations.getString(
                context,
                'profile.idType',
              ).toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            _RadioRow<IdType>(
              value: IdType.nationalId,
              group: _idType,
              label: AppLocalizations.getString(
                context,
                'profile.idTypeNational',
              ),
              onChanged: (v) => setState(() => _idType = v),
            ),
            _RadioRow<IdType>(
              value: IdType.maisha,
              group: _idType,
              label: AppLocalizations.getString(
                context,
                'profile.idTypeMaisha',
              ),
              onChanged: (v) => setState(() => _idType = v),
            ),

            const SizedBox(height: 16),
            SoftInput(
              controller: _idCtrl,
              label: AppLocalizations.getString(context, 'profile.idNumber'),
              hint: 'e.g. 12345678',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 20),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final loading = state.kycStatus == KycStatus.verifying;
                return AppPrimaryButton(
                  onPressed: (!_canSubmit || loading) ? null : _submit,
                  label: AppLocalizations.getString(
                    context,
                    'profile.updateIdentity',
                  ),
                    borderRadius: 12,
                  color: AppColors.primaryColor,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioRow<T> extends StatelessWidget {
  final T value;
  final T group;
  final String label;
  final ValueChanged<T> onChanged;

  const _RadioRow({
    required this.value,
    required this.group,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == group;
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? cs.primary : cs.outlineVariant,
                  width: selected ? 6 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
