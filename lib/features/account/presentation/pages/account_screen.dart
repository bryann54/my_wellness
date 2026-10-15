import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/notifiers/locale_provider.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_version_footer.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/account/presentation/widgets/account_header.dart';
import 'package:my_wellness/features/account/presentation/widgets/account_menu_section.dart';
import 'package:my_wellness/features/account/presentation/widgets/dialogs/logout_dialog.dart';
import 'package:my_wellness/features/account/presentation/widgets/error_view.dart';
import 'package:my_wellness/features/account/presentation/widgets/loading_view.dart';
import 'package:my_wellness/features/account/presentation/widgets/support_menu_section.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';

@RoutePage()
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(const FetchProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
      listener: _handleStateChanges,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            if (state.status == AccountStatus.loading &&
                state.profile == null) {
              return const AccountShimmer();
            }
            if (state.status == AccountStatus.error && state.profile == null) {
              return ErrorView(
                onRetry: () =>
                    context.read<AccountBloc>().add(const FetchProfileEvent()),
              );
            }
            return _buildContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AccountState state) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            context.read<AccountBloc>().add(const FetchProfileEvent());
            await Future.delayed(const Duration(milliseconds: 500));
          },
        ),
        if (state.profile != null)
          AccountHeader(
            profile: state.profile!,
            onLogout: () => LogoutDialog.show(context),
          ),
        SliverToBoxAdapter(
          child: _buildMenuSections(context, state, localeProvider.locale),
        ),
      ],
    );
  }

  Widget _buildMenuSections(
    BuildContext context,
    AccountState state,
    Locale currentLocale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          label: AppLocalizations.getString(context, 'profile.account'),
        ),
        AccountMenuSection(state: state, currentLocale: currentLocale),
        _SectionLabel(
          label: AppLocalizations.getString(context, 'profile.getHelp'),
        ),
        const SupportMenuSection(),
        const SizedBox(height: AppSpacing.xl),
        const Center(child: AppVersionFooter()),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  void _handleStateChanges(BuildContext context, AccountState state) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    if (state.currentLang != localeProvider.locale.languageCode) {
      localeProvider.setLocale(Locale(state.currentLang));
    }
    const updateStatuses = {AccountStatus.updated, AccountStatus.updating};
    if (updateStatuses.contains(state.status)) return;

    if (state.successMessage != null) {
      _showSuccessMessage(context, state.successMessage!);
      context.read<AccountBloc>().add(const ClearErrorEvent());
    }
    if (state.errorMessage != null) {
      _showErrorMessage(context, state.errorMessage!);
      context.read<AccountBloc>().add(const ClearErrorEvent());
    }
    if (state.status == AccountStatus.deleted) {
      context.read<AuthBloc>().add(const SignOutEvent(allDevices: false));
      context.router.pushAndPopUntil(
        const LoginRoute(),
        predicate: (_) => false,
      );
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () =>
              context.read<AccountBloc>().add(const FetchProfileEvent()),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
