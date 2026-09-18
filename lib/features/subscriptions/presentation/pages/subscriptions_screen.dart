import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/empty_state_view.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/subscriptions/presentation/bloc/subscriptions_bloc.dart';
import 'package:my_wellness/features/subscriptions/presentation/widgets/entitlement_tile.dart';
import 'package:my_wellness/features/subscriptions/presentation/widgets/restore_button.dart';
import 'package:my_wellness/features/subscriptions/presentation/widgets/subscription_tile.dart';
import 'package:my_wellness/features/subscriptions/presentation/widgets/subscription_tile_shimmer.dart';

@RoutePage()
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<AccountBloc>().state.profile;
      final userId = profile?.memberCode ?? '';
      if (userId.isNotEmpty) {
        context.read<SubscriptionsBloc>().add(InitializeRC(userId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionsBloc, SubscriptionState>(
      listenWhen: (p, c) =>
          c.status == SubscriptionStatus.success ||
          c.status == SubscriptionStatus.error,
      listener: (context, state) {
        final isError = state.status == SubscriptionStatus.error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isError
                  ? (state.errorMessage ?? 'Something went wrong')
                  : (state.successMessage ?? 'Done'),
            ),
            backgroundColor: isError
                ? Theme.of(context).colorScheme.error
                : const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            CustomAppBar(
              title: AppLocalizations.getString(context, 'subscription.title'),
              isHome: false,
            ),
          ],
          body: BlocBuilder<SubscriptionsBloc, SubscriptionState>(
            builder: (context, state) {
              if (state.status == SubscriptionStatus.loading) {
                return _buildLoadingState();
              }

              final active =
                  state.entitlements.values.where((e) => e.isActive).toList();

              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  context.read<SubscriptionsBloc>()
                    ..add(LoadOfferings())
                    ..add(LoadEntitlements());
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    if (state.offerings.isEmpty) ...[
                      EmptyStateView(
                        imagePath: 'assets/images/empty_cart.png',
                        floatingIcon: FontAwesomeIcons.ccPaypal.data,
                        title: AppLocalizations.getString(
                          context,
                          'subscription.no_plan',
                        ),
                        subtitle: AppLocalizations.getString(
                          context,
                          'subscription.no_plans',
                        ),
                      ),
                    ] else ...[
                      ...state.offerings.asMap().entries.map((e) {
                        final pkg = e.value;
                        final isActive = state.entitlements.values.any(
                          (ent) =>
                              ent.isActive &&
                              ent.productIdentifier == pkg.productIdentifier,
                        );
                        return SubscriptionPackageTile(
                          package: pkg,
                          isActive: isActive,
                          index: e.key,
                          onTap: isActive
                              ? () {}
                              : () => context.read<SubscriptionsBloc>().add(
                                    PurchasePackage(pkg),
                                  ),
                        );
                      }),
                    ],

                    //active one
                    if (active.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text(
                        AppLocalizations.getString(
                          context,
                          'subscription.activeSubs',
                        ),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.45),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...active.asMap().entries.map(
                            (e) => EntitlementTile(
                                entitlement: e.value, index: e.key),
                          ),
                    ],

                    // ── Restore ────────────────────────────────────
                    const SizedBox(height: 16),
                    const SizedBox(height: 24),
                    RestoreButton(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} // ── Restore button ────────────────────────────────────────────────────────────

Widget _buildLoadingState() => ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: 5,
      itemBuilder: (_, index) => const SubscriptionPackageShimmer(),
    );
