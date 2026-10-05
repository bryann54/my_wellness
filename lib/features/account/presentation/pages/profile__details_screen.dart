
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/editable_details_section.dart';
import 'package:my_wellness/features/account/presentation/widgets/profile_details/verified_identity_section.dart';

@RoutePage()
class ProfileDetailsScreen extends StatelessWidget {
  final HealthProfile profile;
  const ProfileDetailsScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AccountBloc>(),
      child: BlocListener<AccountBloc, AccountState>(
        listenWhen: (p, c) =>
            p.status != c.status ||
            p.successMessage != c.successMessage ||
            p.errorMessage != c.errorMessage,
        listener: (context, state) {
          if (state.status == AccountStatus.updated) {
            AppSnackbar.success(
              context,
              state.successMessage ??
                  AppLocalizations.getString(context, 'profile.updateSuccess'),
            );
            context.read<AccountBloc>().add(const ClearErrorEvent());
            context.router.maybePop();
          } else if (state.status == AccountStatus.error &&
              state.errorMessage != null) {
            AppSnackbar.error(context, state.errorMessage!);
            context.read<AccountBloc>().add(const ClearErrorEvent());
          }
        },
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              CustomAppBar(
                title: AppLocalizations.getString(
                  context,
                  'profile.detailsTitle',
                ),
                isHome: false,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VerifiedIdentitySection(profile: profile),
                      const SizedBox(height: 20),
                      EditableDetailsSection(profile: profile),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
