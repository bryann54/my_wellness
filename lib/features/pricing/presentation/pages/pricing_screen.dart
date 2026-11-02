import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/custom_alert_dialog.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/pricing/domain/entities/payment_destination.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_catalog.dart';
import 'package:my_wellness/features/pricing/presentation/bloc/pricing_bloc.dart';
import 'package:my_wellness/features/pricing/presentation/pages/payment_outcome_screen.dart';

enum _Step { choose, standalone, combined, createMyPackage, review }

enum _BuilderMode { standalone, combined, custom }

@RoutePage()
class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<PricingBloc>()..add(const LoadPricingPackagesEvent()),
    child: const _PricingRoot(),
  );
}

class _PricingRoot extends StatefulWidget {
  const _PricingRoot();

  @override
  State<_PricingRoot> createState() => _PricingRootState();
}

class _PricingRootState extends State<_PricingRoot> {
  _Step _step = _Step.choose;
  _BuilderMode _builderMode = _BuilderMode.custom;

  // Shared with the builder — the last-chosen selection in review.
  final List<String> _selected = [];
  String? _bundle;
  String? _sexualTier;
  String? _monitorTerm;
  String? _opinionTier;

  void _goTo(_Step step) => setState(() => _step = step);

  void _openBuilder(_BuilderMode mode) {
    setState(() {
      _builderMode = mode;
      _step = _Step.createMyPackage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only show the sticky bottom bar during the builder/selection steps
    final showBottomBar = _step == _Step.standalone ||
        _step == _Step.combined ||
        _step == _Step.createMyPackage;

    final hasSelection = _selected.isNotEmpty || _bundle != null;

    return PopScope(
      canPop: _step == _Step.choose,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goTo(_Step.choose);
      },
      child: Scaffold(
        // 1. Pin the Continue button to the bottom
        bottomNavigationBar: showBottomBar && hasSelection
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppPrimaryButton(
                    onPressed: () => _goTo(_Step.review),
                    label: 'Continue',
                    height: 52,
                  ),
                ),
              )
            : null,
        body: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            CustomAppBar(
              title: AppLocalizations.getString(context, 'pricing.title'),
              isHome: false,
            ),
          ],
          body: BlocBuilder<PricingBloc, PricingState>(
            builder: (context, state) {
              if (state.status == PricingStatus.initial ||
                  (state.status == PricingStatus.loading &&
                      state.catalog == null)) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              if (state.status == PricingStatus.error &&
                  state.catalog == null) {
                return _PricingMessage(
                  message:
                      state.errorMessage ??
                      AppLocalizations.getString(context, 'pricing.loadError'),
                  actionLabel: AppLocalizations.getString(
                    context,
                    'common.retry',
                  ),
                  onAction: () => context.read<PricingBloc>().add(
                    const LoadPricingPackagesEvent(refresh: true),
                  ),
                );
              }
              final catalog = state.catalog;
              if (catalog == null) return const SizedBox.shrink();

              return switch (_step) {
                _Step.choose => _ChooseView(
                    catalog: catalog,
                    onStandalone: () => _openBuilder(_BuilderMode.standalone),
                    onCombined: () => _openBuilder(_BuilderMode.combined),
                    onCreate: () => _openBuilder(_BuilderMode.custom),
                    onAllInOne: () {
                      setState(() {
                        _bundle = 'all_in_one';
                        _selected.clear();
                        _builderMode = _BuilderMode.custom;
                        _step = _Step.review;
                      });
                      context.read<PricingBloc>().add(
                        const QuotePricingSelectionEvent(
                          {'bundle': 'all_in_one'},
                        ),
                      );
                    },
                  ),
                _Step.standalone ||
                _Step.combined ||
                _Step.createMyPackage => _BuilderView(
                    catalog: catalog,
                    mode: _builderMode,
                    selected: _selected,
                    bundle: _bundle,
                    sexualTier: _sexualTier,
                    monitorTerm: _monitorTerm,
                    opinionTier: _opinionTier,
                    onSelectionChanged: (next) => setState(() {
                      _selected
                        ..clear()
                        ..addAll(next);
                      if (next.isNotEmpty) _bundle = null;
                    }),
                    onBundleChanged: (next) => setState(() {
                      _bundle = next;
                      if (next != null) _selected.clear();
                    }),
                    onSexualTierChanged: (v) => setState(() => _sexualTier = v),
                    onMonitorTermChanged: (v) => setState(() => _monitorTerm = v),
                    onOpinionTierChanged: (v) => setState(() => _opinionTier = v),
                    onBack: () => _goTo(_Step.choose),
                  ),
                _Step.review => _ReviewView(
                    catalog: catalog,
                    onBack: () => _goTo(_Step.createMyPackage),
                    onPaid: () {
                      _goTo(_Step.choose);
                    },
                  ),
              };
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Choose view
// ─────────────────────────────────────────────────────────────────────────────

class _ChooseView extends StatelessWidget {
  final PricingCatalog catalog;
  final VoidCallback onStandalone;
  final VoidCallback onCombined;
  final VoidCallback onCreate;
  final VoidCallback onAllInOne;

  const _ChooseView({
    required this.catalog,
    required this.onStandalone,
    required this.onCombined,
    required this.onCreate,
    required this.onAllInOne,
  });

  @override
  Widget build(BuildContext context) {
    final visibleAllInOneServices =
        catalog.allInOne?.serviceIds
            .where((id) => !PricingCatalog.hiddenServiceIds.contains(id))
            .length ??
        0;
    final countWord = switch (visibleAllInOneServices) {
      8 => 'eight',
      9 => 'nine',
      10 => 'ten',
      _ => '$visibleAllInOneServices',
    };

    final cheapestStandalone = catalog.visibleServices
        .where((s) => (s.basePriceKes ?? 0) > 0)
        .fold<int>(
          catalog.visibleServices.isNotEmpty ? 200 : 0,
          (prev, s) => (s.basePriceKes ?? 0) < prev ? s.basePriceKes! : prev,
        );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _ChooseCard(
          badge: 'For individual health needs',
          title: 'Choose What Works for You',
          subtitle: 'From ${formatPrice(cheapestStandalone)} / year',
          action: 'Explore individual services',
          onTap: onStandalone,
        ),
        const SizedBox(height: AppSpacing.md),
        _ChooseCard(
          badge: 'Complete annual package',
          title: 'Everything in One Package',
          subtitle: catalog.allInOne == null
              ? ''
              : '${formatPrice(catalog.allInOne!.priceKes)} / year',
          helper: 'One annual payment for all $countWord service areas',
          primaryAction: catalog.allInOne == null
              ? null
              : 'Choose All-in-One · ${formatPrice(catalog.allInOne!.priceKes)}',
          onPrimary: catalog.allInOne == null ? null : onAllInOne,
          secondaryAction: 'View Everything Included',
          onSecondary: onAllInOne,
          onTap: onAllInOne,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'MORE WAYS TO CHOOSE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _MiniChoice(
          title: 'Standalone Packages',
          subtitle: 'Choose one health service.',
          onTap: onStandalone,
        ),
        _MiniChoice(
          title: 'Combined Packages',
          subtitle: 'Choose a discounted bundle, including All-in-One.',
          onTap: onCombined,
        ),
        _MiniChoice(
          title: 'Create My Package',
          subtitle: 'Save KSh 50 on each additional paid service.',
          onTap: onCreate,
        ),
      ],
    );
  }
}

class _ChooseCard extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final String? helper;
  final String? action;
  final VoidCallback? onTap;
  final String? primaryAction;
  final VoidCallback? onPrimary;
  final String? secondaryAction;
  final VoidCallback? onSecondary;

  const _ChooseCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    this.helper,
    this.action,
    this.onTap,
    this.primaryAction,
    this.onPrimary,
    this.secondaryAction,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              badge.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ), 
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (helper != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                helper!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
            if (primaryAction != null) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  onPressed: onPrimary,
                  label: primaryAction!,
                  height: 48,
                ),
              ),
            ],
            if (secondaryAction != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: onSecondary,
                  child: Text(
                    secondaryAction!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
            if (action != null && primaryAction == null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                action!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniChoice extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MiniChoice({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: cs.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Builder view
// ─────────────────────────────────────────────────────────────────────────────

class _BuilderView extends StatelessWidget {
  final PricingCatalog catalog;
  final _BuilderMode mode;
  final List<String> selected;
  final String? bundle;
  final String? sexualTier;
  final String? monitorTerm;
  final String? opinionTier;
  final void Function(List<String>) onSelectionChanged;
  final void Function(String?) onBundleChanged;
  final ValueChanged<String?> onSexualTierChanged;
  final ValueChanged<String?> onMonitorTermChanged;
  final ValueChanged<String?> onOpinionTierChanged;
  final VoidCallback onBack;

  const _BuilderView({
    required this.catalog,
    required this.mode,
    required this.selected,
    required this.bundle,
    required this.sexualTier,
    required this.monitorTerm,
    required this.opinionTier,
    required this.onSelectionChanged,
    required this.onBundleChanged,
    required this.onSexualTierChanged,
    required this.onMonitorTermChanged,
    required this.onOpinionTierChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final profile = context.read<AccountBloc>().state.profile;
    final diagnosed = profile?.cancerDiagnosed == true;

    final services = catalog.visibleServices;
    final visibleBundles = catalog.visibleCombos;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl, // Padding at bottom to avoid being hidden by bottom nav
      ),
      children: [
        Text(
          mode == _BuilderMode.standalone
              ? 'Standalone Packages'
              : mode == _BuilderMode.combined
              ? 'Combined Packages'
              : 'Create My Package',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (mode != _BuilderMode.combined) ...[
          _sectionTitle(context, 'Select a service'),
          for (final service in services)
            if (!(diagnosed && service.serviceId == 'cancer'))
              _ServiceTile(
                service: service,
                selected: selected.contains(service.serviceId),
                onChanged: (value) {
                  final next = List<String>.of(selected);
                  if (value) {
                    if (!next.contains(service.serviceId)) {
                      next.add(service.serviceId);
                    }
                  } else {
                    next.remove(service.serviceId);
                  }
                  onSelectionChanged(next);
                },
              ),
        ],
        if (mode != _BuilderMode.standalone) ...[
          const SizedBox(height: AppSpacing.md),
          _sectionTitle(context, 'Select a bundle'),
          for (final b in visibleBundles)
            _BundleTile(
              bundle: b,
              selected: bundle == b.bundleId,
              onTap: () =>
                  onBundleChanged(bundle == b.bundleId ? null : b.bundleId),
            ),
        ],
        if (mode == _BuilderMode.custom) ...[
          const SizedBox(height: AppSpacing.md),
          _sectionTitle(context, 'Personalise your package'),
          if (selected.contains('sexual') || bundle == 'cs')
            _TierPicker(
              label: 'Sexual health age category',
              value: sexualTier,
              options: const {'youth': '18–24', 'adult': '25+'},
              onChanged: onSexualTierChanged,
            ),
          if (selected.contains('monitor'))
            _TierPicker(
              label: 'Monitoring billing term',
              value: monitorTerm,
              options: const {'monthly': 'Monthly', 'annual': 'Annual'},
              onChanged: onMonitorTermChanged,
            ),
          if (selected.contains('opinion'))
            _TierPicker(
              label: 'Second opinion appointment',
              value: opinionTier,
              options: const {'gp': 'GP', 'consultant': 'Consultant'},
              onChanged: onOpinionTierChanged,
            ),
        ],
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Review view
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewView extends StatefulWidget {
  final PricingCatalog catalog;
  final VoidCallback onBack;
  final VoidCallback onPaid;

  const _ReviewView({
    required this.catalog,
    required this.onBack,
    required this.onPaid,
  });

  @override
  State<_ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<_ReviewView> {
  bool _cancerQuestionAnswered = false;

  Future<void> _openOutcome(PricingDestination dest) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PricingBloc>(),
          child: PaymentOutcomeScreen(
            initialDestination: dest,
            onNavigate: (d) {
              // §2 destinations. Real routes live outside this feature;
              // wire the concrete route here when the app owns them.
            },
          ),
        ),
      ),
    );
    if (mounted) widget.onPaid();
  }

  Future<bool> _ensureCancerDeclared() async {
    if (_cancerQuestionAnswered) return true;
    final profile = context.read<AccountBloc>().state.profile;
    if (profile?.cancerDiagnosed == true) {
      return true;
    }
    final answered = await CustomAlertDialog.show<bool>(
      context: context,
      dialog: CustomAlertDialog(
        title: 'Have you ever been diagnosed with cancer?',
        message:
            'This helps us recommend the right next step. If you have, we will guide you to free follow-up guidance instead.',
        type: DialogType.info,
        confirmText: 'No, never',
        cancelText: 'Yes, I have',
        showCancelButton: true,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    if (answered == null) return false;
    _cancerQuestionAnswered = true;
    // TODO: PATCH /api/auth/cancer-diagnosis/ when that endpoint lands in
    // the account feature. For now the answer only gates the flow.
    return answered;
  }

  Future<void> _handlePay(BuildContext context, PricingState state) async {
    final quote = state.quote;
    if (quote == null) return;
    final hasCancer = quote.lines.any((l) => l.serviceId == 'cancer');
    if (hasCancer) {
      final proceed = await _ensureCancerDeclared();
      if (!proceed) {
        // User said they are diagnosed — offer the guidance route and
        // stop the purchase.
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please follow the free diagnosed-cancer guidance. A navigator will contact you.',
              ),
            ),
          );
        }
        return;
      }
    }

    if (!context.mounted) return;

    var phone = context.read<AccountBloc>().state.profile?.phone ?? '';
    final confirmed = await CustomAlertDialog.show<String>(
      context: context,
      dialog: CustomAlertDialog(
        title: 'M-Pesa phone number',
        message:
            'Confirm the number for your M-Pesa prompt. You can edit it if needed.',
        type: DialogType.info,
        content: _PhonePromptContent(
          initialPhone: phone,
          onChanged: (value) => phone = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(phone.trim()),
            child: const Text('Send prompt'),
          ),
        ],
      ),
    );
    if (confirmed == null || confirmed.isEmpty) return;

    final selection = state.lastQuotedSelection;
    if (selection == null) return;

    context.read<PricingBloc>().add(
      CheckoutPricingSelectionEvent(selection: selection, phone: confirmed),
    );

    final destination =
        state.destination?.destination ?? PricingDestination.dashboard;
    await _openOutcome(destination);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PricingBloc>().state;
    final quote = state.quote;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Review Your Package',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (quote == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator.adaptive(),
            ),
          )
        else ...[
          _QuoteCard(quote: quote, catalog: widget.catalog),
          if (state.checkoutError != null) ...[
            const SizedBox(height: 12),
            Text(
              state.checkoutError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            onPressed: state.checkoutLoading
                ? null
                : () => _handlePay(context, state),
            label: state.checkoutLoading
                ? 'Starting M-Pesa…'
                : 'Pay with M-Pesa · ${formatPrice(quote.totalKes)}',
            height: 52,
            isLoading: state.checkoutLoading,
          ),
        ],
      ],
    );
  }
}


class _ServiceTile extends StatelessWidget {
  final PricingService service;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _ServiceTile({
    required this.service,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppDurations.fast,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: selected
            ? cs.primaryContainer.withValues(alpha: 0.5)
            : cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: selected
              ? cs.primary
              : cs.outlineVariant.withValues(alpha: 0.6),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => onChanged(!selected),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox on the far left
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: selected,
                    onChanged: (value) => onChanged(value == true),
                    activeColor: cs.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              
              // Title and Price stacked vertically to avoid overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: selected ? cs.primary : cs.onSurface,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                   
                      if (service.shortDescription.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        service.shortDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                     const SizedBox(height: 4),
                    Text(
                      service.priceDisplay,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BundleTile extends StatelessWidget {
  final PricingBundle bundle;
  final bool selected;
  final VoidCallback onTap;

  const _BundleTile({
    required this.bundle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppDurations.fast,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: selected
            ? cs.primaryContainer.withValues(alpha: 0.5)
            : cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: selected
              ? cs.primary
              : cs.outlineVariant.withValues(alpha: 0.6),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bundle.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: selected ? cs.primary : cs.onSurface,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatPrice(bundle.priceKes),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (bundle.description.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        bundle.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TierPicker extends StatelessWidget {
  final String label;
  final String? value;
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;

  const _TierPicker({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: options.entries
                .map(
                  (entry) => ButtonSegment<String>(
                    value: entry.key,
                    label: Text(entry.value),
                  ),
                )
                .toList(growable: false),
            selected: value == null ? const {} : {value!},
            emptySelectionAllowed: true,
            onSelectionChanged: (selection) => onChanged(
              selection.isEmpty || selection.first == value
                  ? null
                  : selection.first,
            ),
            showSelectedIcon: false, 
          ),
        ),
      ],
    ),
  );
}

class _QuoteCard extends StatelessWidget {
  final PricingQuote quote;
  final PricingCatalog catalog;

  const _QuoteCard({required this.quote, required this.catalog});

  @override
  Widget build(BuildContext context) {
    final names = {
      for (final service in catalog.services) service.serviceId: service.name,
    };
    final scheme = Theme.of(context).colorScheme;
    final visibleLines = quote.lines.where(
      (l) => !PricingCatalog.hiddenServiceIds.contains(l.serviceId),
    );
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final line in visibleLines)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        names[line.serviceId] ?? line.serviceId,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatPrice(line.priceKes),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (line.isFree)
                          Text(
                            'Included',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.primary,
                            ),
                          )
                        else if (line.isDiscounted)
                          Text(
                            'Discount applied',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            if (quote.discountKes > 0) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discount',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '- ${formatPrice(quote.discountKes)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  formatPrice(quote.totalKes),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhonePromptContent extends StatefulWidget {
  final String initialPhone;
  final ValueChanged<String> onChanged;

  const _PhonePromptContent({
    required this.initialPhone,
    required this.onChanged,
  });

  @override
  State<_PhonePromptContent> createState() => _PhonePromptContentState();
}

class _PhonePromptContentState extends State<_PhonePromptContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.phone,
        autofocus: true,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: 'Phone number',
          hintText: '2547XXXXXXXX',
          prefixIcon: const Icon(Icons.phone_rounded),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: scheme.outline),
          ),
                 focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _PricingMessage extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _PricingMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          if (onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel ?? 'Retry'),
            ),
          ],
        ],
      ),
    ),
  );
}
