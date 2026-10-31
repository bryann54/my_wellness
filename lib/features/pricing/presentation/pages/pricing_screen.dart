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
import 'package:my_wellness/features/pricing/domain/entities/pricing_catalog.dart';
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

class _PricingBody extends StatefulWidget {
  const _PricingBody();

  @override
  State<_PricingBody> createState() => _PricingBodyState();
}

class _PricingBodyState extends State<_PricingBody> {
  int _step = 0;
  final List<String> _selected = [];
  String? _bundle;
  String? _sexualTier;
  String? _monitorTerm;
  String? _opinionTier;

  void _requestQuote() {
    final age = context.read<AccountBloc>().state.profile?.age;
    final resolvedSexualTier = age != null && age >= 18
        ? (age <= 24 ? 'youth' : 'adult')
        : _sexualTier;
    context.read<PricingBloc>().add(
      QuotePricingSelectionEvent({
        if (_bundle == null) 'service_ids': List<String>.of(_selected),
        'sexual_age_tier': resolvedSexualTier,
        'monitor_term': _monitorTerm,
        'opinion_clinician_tier': _opinionTier,
        'bundle': _bundle,
      }),
    );
  }

  void _toggleService(String id, bool selected) {
    setState(() {
      _bundle = null;
      if (selected) {
        if (!_selected.contains(id)) _selected.add(id);
      } else {
        _selected.remove(id);
      }
    });
    _requestQuote();
  }

  void _chooseBundle(String id) {
    setState(() {
      _bundle = id;
      _selected.clear();
    });
    _requestQuote();
  }

  void _toggleBundle() {
    setState(() => _bundle = null);
    _requestQuote();
  }

  @override
  Widget build(BuildContext context) {
    String tr(String key) => AppLocalizations.getString(context, key);
    final age = context.watch<AccountBloc>().state.profile?.age;
    final lockedTier = age != null && age >= 18
        ? (age <= 24 ? 'youth' : 'adult')
        : null;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step == 1) setState(() => _step = 0);
      },
      child: Scaffold(
        bottomNavigationBar: BlocBuilder<PricingBloc, PricingState>(
          builder: (context, state) {
            final canContinue = _selected.isNotEmpty || _bundle != null;
            final canPay =
                state.quote != null &&
                !state.quoteLoading &&
                !_needsTier &&
                !state.checkoutLoading;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: AppPrimaryButton(
                  onPressed: _step == 0
                      ? (canContinue ? _continueToPackage : null)
                      : (canPay
                            ? () {
                                final catalog = state.catalog;
                                if (catalog != null) {
                                  _reviewAndCheckout(context, state, catalog);
                                }
                              }
                            : null),
                  label: _step == 0
                      ? 'Continue'
                      : state.checkoutLoading
                      ? 'Starting M-Pesa…'
                      : 'Review & pay${state.quote == null ? '' : ' · ${formatPrice(state.quote!.totalKes)}'}',
                  isLoading: _step == 1 && state.checkoutLoading,
                  height: 52,
                ),
              ),
            );
          },
        ),
        body: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            CustomAppBar(title: tr('pricing.title'), isHome: false),
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
                  message: state.errorMessage ?? tr('pricing.loadError'),
                  actionLabel: tr('common.retry'),
                  onAction: () => context.read<PricingBloc>().add(
                    const LoadPricingPackagesEvent(refresh: true),
                  ),
                );
              }
              final catalog = state.catalog;
              if (catalog == null) return const SizedBox.shrink();

              final services = catalog.services
                  .where((service) => service.serviceId != 'workplace')
                  .toList(growable: false);
              final visibleBundles = catalog.combos
                  .where((bundle) => bundle.bundleId != 'workplace')
                  .toList(growable: false);
              final allInOneCount =
                  catalog.allInOne?.serviceIds
                      .where((id) => id != 'workplace')
                      .length ??
                  8;
              final countWord = switch (allInOneCount) {
                8 => 'eight',
                9 => 'nine',
                _ => '$allInOneCount',
              };

              return RefreshIndicator.adaptive(
                onRefresh: () => _refresh(context),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  children: [
                    Text(
                      _step == 0 ? 'Choose What Works for You' : 'My Package',
                      style: _heading(context),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _step == 0
                          ? 'Select a service or package to continue.'
                          : 'Review your selection and choose any required options.',
                      style: _body(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_step == 0) ...[
                      _sectionTitle(context, 'Standalone Packages'),
                      for (final service in services)
                        _ServiceTile(
                          service: service,
                          selected: _selected.contains(service.serviceId),
                          onChanged: (value) =>
                              _toggleService(service.serviceId, value),
                        ),
                      _sectionTitle(context, 'Combined Packages'),
                      for (final bundle in visibleBundles)
                        _BundleTile(
                          bundle: bundle,
                          selected: _bundle == bundle.bundleId,
                          onTap: () => _chooseBundle(bundle.bundleId),
                        ),
                      if (catalog.allInOne case final all?) ...[
                        _sectionTitle(context, 'Everything in One Package'),
                        _BundleTile(
                          bundle: all,
                          selected: _bundle == 'all_in_one',
                          subtitle:
                              'One annual payment for all $countWord service areas',
                          onTap: () => _chooseBundle('all_in_one'),
                        ),
                      ],
                    ] else ...[
                      _sectionTitle(context, 'Selected package'),
                      if (_bundle != null)
                        _BundleTile(
                          bundle:
                              _bundleForId(
                                _bundle!,
                                visibleBundles,
                                catalog.allInOne,
                              ) ??
                              PricingBundle(
                                bundleId: _bundle!,
                                name: _bundle!,
                                description: '',
                                serviceIds: const [],
                                priceKes: 0,
                              ),
                          selected: true,
                          onTap: _toggleBundle,
                        )
                      else
                        for (final service in services.where(
                          (service) => _selected.contains(service.serviceId),
                        ))
                          _ServiceTile(
                            service: service,
                            selected: true,
                            onChanged: (value) =>
                                _toggleService(service.serviceId, value),
                          ),
                      _sectionTitle(context, 'Create My Package'),
                    ],
                    if (_step == 1 && _selected.contains('sexual')) ...[
                      _TierPicker(
                        label: 'Sexual health age category',
                        value: lockedTier ?? _sexualTier,
                        options: const {'youth': '18–24', 'adult': '25+'},
                        locked: lockedTier != null,
                        onChanged: (value) {
                          setState(() => _sexualTier = value);
                          _requestQuote();
                        },
                      ),
                      if (lockedTier != null)
                        const Text("Set from your account's age."),
                    ],
                    if (_step == 1 && _bundle == 'cs') ...[
                      _TierPicker(
                        label: 'Sexual health age category',
                        value: lockedTier ?? _sexualTier,
                        options: const {'youth': '18–24', 'adult': '25+'},
                        locked: lockedTier != null,
                        onChanged: (value) {
                          setState(() => _sexualTier = value);
                          _requestQuote();
                        },
                      ),
                      if (lockedTier != null)
                        const Text("Set from your account's age."),
                    ],
                    if (_step == 1 && _selected.contains('monitor'))
                      _TierPicker(
                        label: 'Monitoring billing term',
                        value: _monitorTerm,
                        options: const {
                          'monthly': 'Monthly',
                          'annual': 'Annual',
                        },
                        onChanged: (value) {
                          setState(() => _monitorTerm = value);
                          _requestQuote();
                        },
                      ),
                    if (_step == 1 && _selected.contains('opinion'))
                      _TierPicker(
                        label: 'Second opinion appointment',
                        value: _opinionTier,
                        options: const {'gp': 'GP', 'consultant': 'Consultant'},
                        onChanged: (value) {
                          setState(() => _opinionTier = value);
                          _requestQuote();
                        },
                      ),
                    if (_step == 1 && state.quoteLoading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ),
                    if (_step == 1 &&
                        state.quoteError != null &&
                        !_isMissingTierError(state.quoteError!))
                      Text(
                        state.quoteError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    if (_step == 1 && _needsTier && state.quote == null)
                      Text(_tierPrompt, style: _body(context)),
                    if (_step == 1 && state.quote != null) ...[
                      const SizedBox(height: 16),
                      _QuoteCard(
                        quote: state.quote!,
                        catalog: catalog,
                        onCombo: state.quote!.cheaperComboId == null
                            ? null
                            : () => _chooseBundle(state.quote!.cheaperComboId!),
                      ),
                      if (state.checkoutError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            state.checkoutError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      if (state.payment != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'M-Pesa prompt sent to ${state.payment!.phoneNumber}. Enter your PIN on your phone to continue.',
                          ),
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PricingBundle? _bundleForId(
    String id,
    List<PricingBundle> combos,
    PricingBundle? allInOne,
  ) {
    if (id == 'all_in_one') return allInOne;
    for (final bundle in combos) {
      if (bundle.bundleId == id) return bundle;
    }
    return null;
  }

  void _continueToPackage() {
    if (_selected.isEmpty && _bundle == null) return;
    setState(() => _step = 1);
    if (context.read<PricingBloc>().state.quote == null) _requestQuote();
  }

  bool get _needsTier =>
      ((_selected.contains('sexual') || _bundle == 'cs') &&
          _effectiveSexualTier == null) ||
      (_selected.contains('monitor') && _monitorTerm == null) ||
      (_selected.contains('opinion') && _opinionTier == null);

  String get _tierPrompt {
    if ((_selected.contains('sexual') || _bundle == 'cs') &&
        _effectiveSexualTier == null) {
      return 'Select an age category above to see the price.';
    }
    if (_selected.contains('monitor') && _monitorTerm == null) {
      return 'Select a billing term above to see the price.';
    }
    return 'Select an appointment type above to see the price.';
  }

  String? get _effectiveSexualTier {
    final age = context.read<AccountBloc>().state.profile?.age;
    if (age != null && age >= 18) return age <= 24 ? 'youth' : 'adult';
    return _sexualTier;
  }

  bool _isMissingTierError(String error) =>
      error.contains('sexual_age_tier') ||
      error.contains('monitor_term') ||
      error.contains('opinion_clinician_tier');

  Future<void> _reviewAndCheckout(
    BuildContext context,
    PricingState state,
    PricingCatalog catalog,
  ) async {
    final quote = state.quote;
    if (quote == null) return;
    final labels = {
      for (final service in catalog.services) service.serviceId: service.name,
    };
    final proceed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Review Your Package', style: _heading(context)),
              const SizedBox(height: 12),
              for (final line in quote.lines.where(
                (line) => line.serviceId != 'workplace',
              ))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(labels[line.serviceId] ?? line.serviceId),
                  trailing: Text(
                    line.isFree ? 'Included' : formatPrice(line.priceKes),
                  ),
                ),
              const Divider(),
              Text(
                'Total · ${formatPrice(quote.totalKes)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  label: 'Pay with M-Pesa',
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (proceed != true || !mounted || !context.mounted) return;

    var enteredPhone = context.read<AccountBloc>().state.profile?.phone ?? '';
    final phone = await CustomAlertDialog.show<String>(
      context: context,
      dialog: CustomAlertDialog(
        title: 'M-Pesa phone number',
        message:
            'Confirm the number for your M-Pesa prompt. You can edit it if needed.',
        type: DialogType.info,
        content: _PhonePromptContent(
          initialPhone: enteredPhone,
          onChanged: (value) => enteredPhone = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(enteredPhone.trim()),
            child: const Text('Send prompt'),
          ),
        ],
      ),
    );
    if (phone == null || phone.isEmpty || !mounted || !context.mounted) return;
    context.read<PricingBloc>().add(
      CheckoutPricingSelectionEvent(
        selection: _selectionPayload(),
        phone: phone,
      ),
    );
  }

  Map<String, dynamic> _selectionPayload() {
    final age = context.read<AccountBloc>().state.profile?.age;
    final resolvedSexualTier = age != null && age >= 18
        ? (age <= 24 ? 'youth' : 'adult')
        : _sexualTier;
    return {
      if (_bundle == null) 'service_ids': List<String>.of(_selected),
      'sexual_age_tier': resolvedSexualTier,
      'monitor_term': _monitorTerm,
      'opinion_clinician_tier': _opinionTier,
      'bundle': _bundle,
    };
  }

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<PricingBloc>();
    final loaded = bloc.stream.firstWhere(
      (s) =>
          s.status == PricingStatus.loaded || s.status == PricingStatus.error,
    );
    bloc.add(const LoadPricingPackagesEvent(refresh: true));
    await loaded;
  }

  TextStyle? _heading(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium;

  TextStyle? _body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;

  Widget _sectionTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.sm),
    child: Text(title, style: Theme.of(context).textTheme.titleLarge),
  );
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.service,
    required this.selected,
    required this.onChanged,
  });
  final PricingService service;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppDurations.fast,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: () => onChanged(!selected),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: (value) => onChanged(value == true),
                    activeColor: scheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      service.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: selected ? scheme.primary : scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              if (service.shortDescription.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  service.shortDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  service.priceDisplay,
                  textAlign: TextAlign.end,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: scheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhonePromptContent extends StatefulWidget {
  const _PhonePromptContent({
    required this.initialPhone,
    required this.onChanged,
  });
  final String initialPhone;
  final ValueChanged<String> onChanged;

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
          filled: false,
          border: OutlineInputBorder(
            borderRadius: AppRadius.mdAll,
            borderSide: BorderSide(color: scheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdAll,
            borderSide: BorderSide(color: scheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdAll,
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _BundleTile extends StatelessWidget {
  const _BundleTile({
    required this.bundle,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });
  final PricingBundle bundle;
  final bool selected;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppDurations.fast,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bundle.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: selected ? scheme.primary : scheme.onSurface,
                      ),
                    ),
                    if ((subtitle ?? bundle.description).isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle ?? bundle.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      formatPrice(bundle.priceKes),
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: scheme.primary),
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

class _TierPicker extends StatelessWidget {
  const _TierPicker({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.locked = false,
  });
  final String label;
  final String? value;
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;
  final bool locked;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(label, style: Theme.of(context).textTheme.titleSmall),
        ),
        SegmentedButton<String>(
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
          onSelectionChanged: locked
              ? null
              : (selection) => onChanged(
                  selection.isEmpty || selection.first == value
                      ? null
                      : selection.first,
                ),
          showSelectedIcon: true,
        ),
      ],
    ),
  );
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.catalog,
    required this.onCombo,
  });
  final PricingQuote quote;
  final PricingCatalog catalog;
  final VoidCallback? onCombo;

  @override
  Widget build(BuildContext context) {
    final visibleLines = quote.lines.where(
      (line) => line.serviceId != 'workplace',
    );
    final names = {
      for (final service in catalog.services) service.serviceId: service.name,
    };
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live package quote',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (final line in visibleLines)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(names[line.serviceId] ?? line.serviceId),
                subtitle: line.isFree
                    ? const Text('Included at no additional cost')
                    : line.isDiscounted
                    ? const Text('Discount applied')
                    : null,
                trailing: Text(formatPrice(line.priceKes)),
              ),
            if (quote.discountKes > 0)
              Text('You save ${formatPrice(quote.discountKes)}'),
            const Divider(),
            Text(
              'Total: ${formatPrice(quote.totalKes)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (quote.cheaperComboId != null && onCombo != null) ...[
              const SizedBox(height: 12),
              Text(
                'A fixed bundle costs less: ${formatPrice(quote.cheaperComboPriceKes ?? 0)}.',
              ),
              TextButton(
                onPressed: onCombo,
                child: const Text('View the lower-priced bundle'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PricingMessage extends StatelessWidget {
  const _PricingMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

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
