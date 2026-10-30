import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_package.dart';
import 'package:my_wellness/features/pricing/presentation/bloc/pricing_bloc.dart';

@RoutePage()
class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<PricingBloc>()..add(const LoadPricingPackagesEvent()),
    child: const _PricingBody(),
  );
}

class _PricingBody extends StatelessWidget {
  const _PricingBody();

  @override
  Widget build(BuildContext context) {
    String tr(String key) => AppLocalizations.getString(context, key);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          CustomAppBar(title: tr('pricing.title'), isHome: false),
        ],
        body: BlocBuilder<PricingBloc, PricingState>(
          builder: (context, state) {
            if (state.status == PricingStatus.initial ||
                state.status == PricingStatus.loading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state.status == PricingStatus.error) {
              return _PricingMessage(
                icon: Icons.wifi_off_rounded,
                message: tr('pricing.loadError'),
                actionLabel: tr('common.retry'),
                onAction: () => context.read<PricingBloc>().add(
                  const LoadPricingPackagesEvent(),
                ),
              );
            }

            if (state.packages.isEmpty) {
              return _PricingMessage(
                icon: Icons.inventory_2_outlined,
                message: tr('pricing.empty'),
              );
            }

            return RefreshIndicator.adaptive(
              onRefresh: () => _refresh(context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Text(
                    tr('pricing.subtitle'),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (final package in state.packages) ...[
                    _PricingPackageCard(package: package),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<PricingBloc>();
    final loaded = bloc.stream.firstWhere(
      (state) =>
          state.status == PricingStatus.loaded ||
          state.status == PricingStatus.error,
    );
    bloc.add(const LoadPricingPackagesEvent());
    await loaded;
  }
}

class _PricingPackageCard extends StatelessWidget {
  const _PricingPackageCard({required this.package});

  final PricingPackage package;

  @override
  Widget build(BuildContext context) {
    String tr(String key) => AppLocalizations.getString(context, key);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dividerColor),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            package.label,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (package.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              package.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (package.priceRules.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final rule in package.priceRules)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _ageRange(context, rule),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      'KES ${rule.priceKes}',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (package.categories.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: package.categories
                  .map((category) => _CategoryChip(label: category))
                  .toList(growable: false),
            ),
          ],
          if (package.unlocksVitalsLogging) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.favorite_border_rounded,
                  size: 17,
                  color: AppColors.vitalBs,
                ),
                const SizedBox(width: 6),
                Text(
                  tr('pricing.vitalsIncluded'),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.vitalBs,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _ageRange(BuildContext context, PackagePriceRule rule) {
    String tr(String key) => AppLocalizations.getString(context, key);
    if (rule.minAge == null && rule.maxAge == null) {
      return tr('pricing.allAges');
    }
    if (rule.minAge != null && rule.maxAge != null) {
      return tr('pricing.ageRange')
          .replaceAll('{min}', '${rule.minAge}')
          .replaceAll('{max}', '${rule.maxAge}');
    }
    if (rule.minAge != null) {
      return tr('pricing.ageFrom').replaceAll('{min}', '${rule.minAge}');
    }
    return tr('pricing.ageTo').replaceAll('{max}', '${rule.maxAge}');
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.vitalBsSurface,
      borderRadius: BorderRadius.circular(999),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: Text(
      label,
      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textPrimary),
    ),
  );
}

class _PricingMessage extends StatelessWidget {
  const _PricingMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: AppColors.primaryColor),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    ),
  );
}
