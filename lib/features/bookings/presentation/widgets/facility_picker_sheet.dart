import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/debouncer.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/app_search_bar.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
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
      showDragHandle: true,
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
  final _debouncer = Debouncer(milliseconds: 300);
  final _search = TextEditingController();
  final _name = TextEditingController();
  final _town = TextEditingController();
  final _county = TextEditingController();
  final _addKey = GlobalKey<FormState>();
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _match();
  }

  @override
  void dispose() {
    _debouncer.cancel();
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
    _debouncer.run(() {
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
    FocusScope.of(context).unfocus();
    if (_addKey.currentState?.validate() != true) return;
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
    return BlocConsumer<BookingsBloc, BookingsState>(
      listenWhen: (p, c) =>
          p.createdFacility != c.createdFacility && c.createdFacility != null,
      listener: (context, state) =>
          Navigator.of(context).pop(state.createdFacility),
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
          ),
          child: _adding ? _buildAddForm(state) : _buildList(state),
        );
      },
    );
  }

  Widget _buildList(BookingsState state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget content;
    if (state.facilitiesLoading) {
      content = ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          ShimmerBox(width: double.infinity, height: 64, radius: 12),
          SizedBox(height: AppSpacing.sm),
          ShimmerBox(width: double.infinity, height: 64, radius: 12),
          SizedBox(height: AppSpacing.sm),
          ShimmerBox(width: double.infinity, height: 64, radius: 12),
        ],
      );
    } else if (state.facilitiesError != null) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.facilitiesError!,
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            TextButton(
              onPressed: _match,
              child: Text(AppLocalizations.getString(context, 'common.retry')),
            ),
          ],
        ),
      );
    } else if (state.facilities.isEmpty) {
      content = Center(
        child: Text(
          AppLocalizations.getString(context, 'bookings.picker.empty'),
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    } else {
      content = ListView.separated(
        itemCount: state.facilities.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => _FacilityTile(
          facility: state.facilities[i],
          onTap: () => Navigator.of(context).pop(state.facilities[i]),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.getString(context, 'bookings.picker.title'),
          style: tt.titleLarge?.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: AppSpacing.md - 4),
        AppSearchBar(
          controller: _search,
          hintText: AppLocalizations.getString(
            context,
            'bookings.picker.searchHint',
          ),
          onChanged: _onQueryChanged,
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: AppSpacing.md - 4),
        Expanded(child: content),
        TextButton.icon(
          onPressed: () => setState(() => _adding = true),
          icon: const Icon(Icons.add_rounded),
          label: Text(
            AppLocalizations.getString(context, 'bookings.picker.add'),
          ),
        ),
      ],
    );
  }

  Widget _buildAddForm(BookingsState state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Form(
      key: _addKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.getString(context, 'bookings.picker.addTitle'),
              style: tt.titleLarge?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            SoftInput(
              controller: _name,
              label: AppLocalizations.getString(
                context,
                'bookings.picker.name',
              ),
              validator: _required,
            ),
            const SizedBox(height: AppSpacing.md),
            SoftInput(
              controller: _town,
              label: AppLocalizations.getString(
                context,
                'bookings.picker.town',
              ),
              validator: _required,
            ),
            const SizedBox(height: AppSpacing.md),
            SoftInput(
              controller: _county,
              label: AppLocalizations.getString(
                context,
                'bookings.picker.county',
              ),
              validator: _required,
            ),
            if (state.facilitiesError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                state.facilitiesError!,
                style: tt.bodySmall?.copyWith(color: cs.error),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              onPressed: state.creatingFacility ? null : _submitNew,
              label: AppLocalizations.getString(context, 'common.save'),
              isLoading: state.creatingFacility,
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: () => setState(() => _adding = false),
                child: Text(AppLocalizations.getString(context, 'common.back')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FacilityTile extends StatelessWidget {
  final Facility facility;
  final VoidCallback onTap;

  const _FacilityTile({required this.facility, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final sub = [
      if (facility.town.isNotEmpty) facility.town,
      if (facility.county.isNotEmpty) facility.county,
      if (facility.distanceKm != null)
        AppLocalizations.t(context, 'bookings.referral.distanceKm', {
          'km': facility.distanceKm!.toStringAsFixed(1),
        }),
    ].join(' · ');

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: AppRadius.mdAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md - 2),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      style: tt.titleSmall?.copyWith(color: cs.onSurface),
                    ),
                    if (sub.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (facility.coversSha)
                Icon(Icons.verified_outlined, size: 20, color: cs.primary),
            ],
          ),
        ),
      ),
    );
  }
}
