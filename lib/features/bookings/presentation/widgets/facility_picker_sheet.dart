import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/debouncer.dart';
import 'package:my_wellness/features/bookings/domain/entities/facility.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/domain/repositories/bookings_repository.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';

class FacilityPickerSheet extends StatefulWidget {
  final ServiceType serviceType;
  final double? userLat;
  final double? userLng;

  const FacilityPickerSheet({
    super.key,
    required this.serviceType,
    this.userLat,
    this.userLng,
  });

  static Future<Facility?> show(
    BuildContext context, {
    required ServiceType serviceType,
    double? userLat,
    double? userLng,
  }) {
    final bloc = context.read<BookingsBloc>();
    return showModalBottomSheet<Facility>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: FacilityPickerSheet(
            serviceType: serviceType,
            userLat: userLat,
            userLng: userLng,
          ),
        ),
      ),
    );
  }

  @override
  State<FacilityPickerSheet> createState() => _FacilityPickerSheetState();
}

class _FacilityPickerSheetState extends State<FacilityPickerSheet> {
  final _search = TextEditingController();
  final _name = TextEditingController();
  final _town = TextEditingController();
  final _county = TextEditingController();
  final _addKey = GlobalKey<FormState>();
  final _searchDebouncer = Debouncer(milliseconds: 350);
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _match();
  }

  @override
  void dispose() {
    _searchDebouncer.cancel();
    _search.dispose();
    _name.dispose();
    _town.dispose();
    _county.dispose();
    super.dispose();
  }

  void _match() => context.read<BookingsBloc>().add(
    MatchFacilitiesEvent(
      widget.serviceType,
      userLat: widget.userLat,
      userLng: widget.userLng,
    ),
  );

  void _onQueryChanged(String value) {
    _searchDebouncer.run(() {
      if (!mounted) return;
      final q = value.trim();
      if (q.length < 2) {
        _match();
      } else {
        context.read<BookingsBloc>().add(SearchFacilitiesEvent(q));
      }
    });
  }

  void _submitNew() {
    if (!_addKey.currentState!.validate()) return;
    context.read<BookingsBloc>().add(
      CreateFacilityEvent(
        CreateFacilityParams(
          name: _name.text.trim(),
          town: _town.text.trim(),
          county: _county.text.trim(),
        ),
      ),
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty)
      ? AppLocalizations.getString(context, 'common.required')
      : null;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    return BlocConsumer<BookingsBloc, BookingsState>(
      listenWhen: (p, c) =>
          p.createdFacility != c.createdFacility && c.createdFacility != null,
      listener: (context, state) =>
          Navigator.of(context).pop(state.createdFacility),
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            insets + AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                title: _adding
                    ? AppLocalizations.getString(context, 'facility.addTitle')
                    : AppLocalizations.getString(
                        context,
                        'facility.chooseTitle',
                      ),
                onAdd: _adding ? null : () => setState(() => _adding = true),
                onBack: _adding ? () => setState(() => _adding = false) : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _adding ? _buildAddForm(state) : _buildList(state),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(BookingsState state) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      key: const ValueKey('list'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _search,
          onChanged: _onQueryChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _search.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _search.clear();
                      _onQueryChanged('');
                    },
                  ),
            hintText: AppLocalizations.getString(
              context,
              'facility.searchHint',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: state.facilitiesLoading
              ? const Center(child: CircularProgressIndicator())
              : state.facilitiesError != null
              ? Center(
                  child: Text(
                    state.facilitiesError!,
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : state.facilities.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.getString(context, 'facility.empty'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: state.facilities.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                  ),
                  itemBuilder: (_, i) {
                    final f = state.facilities[i];
                    final sub = [
                      if (f.town.isNotEmpty) f.town,
                      if (f.county.isNotEmpty) f.county,
                      if (f.distanceKm != null)
                        '${f.distanceKm!.toStringAsFixed(1)} km',
                    ].join(' · ');
                    return ListTile(
                      title: Text(f.name, style: theme.textTheme.titleSmall),
                      subtitle: sub.isEmpty
                          ? null
                          : Text(sub, style: theme.textTheme.bodySmall),
                      trailing: f.coversSha
                          ? const Icon(Icons.verified_outlined, size: 20)
                          : null,
                      onTap: () => Navigator.of(context).pop(f),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAddForm(BookingsState state) {
    final theme = Theme.of(context);
    return Form(
      key: _addKey,
      child: SingleChildScrollView(
        key: const ValueKey('form'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _name,
              validator: _required,
              decoration: InputDecoration(
                labelText: AppLocalizations.getString(context, 'facility.name'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _town,
              validator: _required,
              decoration: InputDecoration(
                labelText: AppLocalizations.getString(context, 'facility.town'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _county,
              validator: _required,
              decoration: InputDecoration(
                labelText: AppLocalizations.getString(
                  context,
                  'facility.county',
                ),
              ),
            ),
            if (state.facilitiesError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                state.facilitiesError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: state.creatingFacility
                        ? null
                        : () => setState(() => _adding = false),
                    child: Text(
                      AppLocalizations.getString(context, 'common.cancel'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: state.creatingFacility ? null : _submitNew,
                    child: state.creatingFacility
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            AppLocalizations.getString(context, 'common.save'),
                          ),
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

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback? onAdd;
  final VoidCallback? onBack;

  const _Header({required this.title, this.onAdd, this.onBack});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: onBack,
            color: cs.onSurface.withValues(alpha: 0.7),
            visualDensity: VisualDensity.compact,
          ),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (onAdd != null)
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: onAdd,
            color: cs.primary,
            tooltip: AppLocalizations.getString(context, 'facility.addCta'),
          ),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
          color: cs.onSurface.withValues(alpha: 0.5),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
