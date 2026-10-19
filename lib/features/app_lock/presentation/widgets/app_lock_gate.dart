import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/app_lock/presentation/bloc/app_lock_bloc.dart';

/// Mount once via `MaterialApp.builder` so the lock covers every route.
class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child, required this.onLogout});

  final Widget child;
  final VoidCallback onLogout;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bloc = context.read<AppLockBloc>();
    switch (state) {
      case AppLifecycleState.paused:
        bloc.add(const AppLockBackgrounded());
      case AppLifecycleState.resumed:
        bloc.add(
          AppLockResumed(
            reason: AppLocalizations.getString(context, 'appLock.unlockReason'),
          ),
        );
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLockBloc, AppLockState>(
      buildWhen: (prev, curr) =>
          prev.isLocked != curr.isLocked ||
          prev.phase != curr.phase ||
          prev.issue != curr.issue,
      builder: (context, state) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Offstage(offstage: state.isLocked, child: widget.child),
            if (state.isLocked)
              _LockScreen(state: state, onLogout: widget.onLogout),
          ],
        );
      },
    );
  }
}

class _LockScreen extends StatefulWidget {
  const _LockScreen({required this.state, required this.onLogout});

  final AppLockState state;
  final VoidCallback onLogout;

  @override
  State<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<_LockScreen> {
  bool _confirmingLogout = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    String l(String key) => AppLocalizations.getString(context, key);

    final busy = widget.state.phase == AppLockPhase.authenticating;
    final message = switch (widget.state.issue) {
      AppLockIssue.lockedOut => l('appLock.lockedOut'),
      AppLockIssue.failed => l('appLock.failed'),
      null => null,
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/logo.png', height: 72),
              const SizedBox(height: AppSpacing.xl),
              if (message != null) ...[
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: cs.error),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (_confirmingLogout) ...[
                Text(
                  l('appLock.logoutConfirmBody'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: widget.onLogout,
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.error,
                    foregroundColor: cs.onError,
                  ),
                  child: Text(l('auth.logout')),
                ),
                TextButton(
                  onPressed: () => setState(() => _confirmingLogout = false),
                  child: Text(l('common.cancel')),
                ),
              ] else ...[
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () => context.read<AppLockBloc>().add(
                          AppLockUnlockRequested(
                            reason: l('appLock.unlockReason'),
                          ),
                        ),
                  icon: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.lock_open_rounded),
                  label: Text(l('appLock.unlock')),
                ),
                TextButton(
                  onPressed: busy
                      ? null
                      : () => setState(() => _confirmingLogout = true),
                  child: Text(l('auth.logout')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
