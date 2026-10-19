import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/features/app_lock/domain/entities/app_lock_status.dart';
import 'package:my_wellness/features/app_lock/presentation/bloc/app_lock_bloc.dart';

class AppLockSetupSheet extends StatelessWidget {
  const AppLockSetupSheet({super.key, required this.security});

  final DeviceSecurity security;

  static Future<void> show(
    BuildContext context, {
    required DeviceSecurity security,
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => AppLockSetupSheet(security: security),
  );

  void _enable(BuildContext context) {
    context.read<AppLockBloc>().add(
      AppLockToggleRequested(
        enabled: true,
        reason: AppLocalizations.getString(context, 'appLock.enableReason'),
      ),
    );
  }

  void _onToggleOutcome(BuildContext context, AppLockState state) {
    final outcome = state.toggleOutcome;
    if (outcome == UnlockOutcome.success) {
      Navigator.of(context).pop();
    } else if (outcome != UnlockOutcome.cancelled) {
      AppSnackbar.error(
        context,
        AppLocalizations.getString(context, 'appLock.failed'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final secured = security == DeviceSecurity.secured;
    String l(String key) => AppLocalizations.getString(context, key);

    return BlocListener<AppLockBloc, AppLockState>(
      listenWhen: (prev, curr) =>
          prev.toggleOutcome != curr.toggleOutcome &&
          curr.toggleOutcome != null,
      listener: _onToggleOutcome,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                secured
                    ? Icons.lock_outline_rounded
                    : Icons.warning_amber_rounded,
                size: 40,
                color: secured ? cs.primary : cs.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l(secured ? 'appLock.setupTitle' : 'appLock.noLockTitle'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l(secured ? 'appLock.setupBody' : 'appLock.noLockBody'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.65),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (secured) ...[
                FilledButton(
                  onPressed: () => _enable(context),
                  child: Text(l('appLock.enable')),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l('appLock.notNow')),
                ),
              ] else
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l('appLock.understand')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
