import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/debouncer.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/section_label.dart';
import 'package:my_wellness/features/bookings/domain/entities/facility.dart';
import 'package:my_wellness/features/bookings/domain/entities/referral.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/domain/repositories/bookings_repository.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_toast_listener.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/facility_picker_sheet.dart';

@RoutePage()
class CreateBookingScreen extends StatelessWidget {
  final ServiceType serviceType;
  final Referral? referral;
  final bool followUp;

  const CreateBookingScreen({
    super.key,
    required this.serviceType,
    this.referral,
    this.followUp = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<BookingsBloc>(),
      child: BookingToastListener(
        child: _CreateBookingBody(
          serviceType: serviceType,
          referral: referral,
          followUp: followUp,
        ),
      ),
    );
  }
}

class _CreateBookingBody extends StatefulWidget {
  final ServiceType serviceType;
  final Referral? referral;
  final bool followUp;

  const _CreateBookingBody({
    required this.serviceType,
    this.referral,
    this.followUp = false,
  });

  @override
  State<_CreateBookingBody> createState() => _CreateBookingBodyState();
}

class _CreateBookingBodyState extends State<_CreateBookingBody> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  final _lawFirm = TextEditingController();
  final _phoneValidatorDebounce = Debouncer(milliseconds: 300);

  Facility? _facility;
  DateTime? _date;
  String _dnaKind = 'health_risk';
  String _tier = 'gp';
  bool _phoneValid = false;

  bool get _locked => widget.referral?.recommendedFacility != null;
  Facility? get _selectedFacility =>
      _locked ? widget.referral!.recommendedFacility : _facility;

  @override
  void initState() {
    super.initState();
    context.read<BookingsBloc>().add(const ResetCreateBookingEvent());
  }

  @override
  void dispose() {
    _phoneValidatorDebounce.cancel();
    _phone.dispose();
    _notes.dispose();
    _lawFirm.dispose();
    super.dispose();
  }

  String _label(BuildContext context) => switch (widget.serviceType) {
    ServiceType.referralVisit =>
      widget.followUp
          ? AppLocalizations.t(context, 'bookings.create.followUpLabel', {
              'category': widget.referral?.escalationCategoryDisplay ?? '',
            })
          : widget.referral?.escalationCategoryDisplay ??
                AppLocalizations.getString(
                  context,
                  'bookings.create.referralVisit',
                ),
    ServiceType.secondOpinion =>
      _tier == 'consultant'
          ? AppLocalizations.getString(
              context,
              'bookings.create.secondOpinionConsultant',
            )
          : AppLocalizations.getString(
              context,
              'bookings.create.secondOpinionGp',
            ),
    ServiceType.dnaTest => AppLocalizations.getString(
      context,
      'bookings.create.dnaTest',
    ),
    ServiceType.navigator => AppLocalizations.getString(
      context,
      'bookings.create.navigator',
    ),
    ServiceType.screening => AppLocalizations.getString(
      context,
      'bookings.create.screening',
    ),
    _ => AppLocalizations.getString(context, 'bookings.create.booking'),
  };

  String? get _fixedPrice => switch (widget.serviceType) {
    ServiceType.dnaTest => 'KES 1,000',
    ServiceType.secondOpinion =>
      _tier == 'consultant' ? 'KES 2,500' : 'KES 1,000',
    _ => null,
  };

  String _normalizePhone(String raw) {
    var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.startsWith('0')) d = '254${d.substring(1)}';
    if (RegExp(r'^[17]\d{8}$').hasMatch(d)) d = '254$d';
    return d;
  }

  String? _validatePhone(String? v) =>
      RegExp(r'^254[17]\d{8}$').hasMatch(_normalizePhone(v ?? ''))
      ? null
      : AppLocalizations.getString(context, 'bookings.create.phoneInvalid');

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickFacility() async {
    HapticFeedback.selectionClick();
    final f = await FacilityPickerSheet.show(
      context,
      serviceType: widget.serviceType,
    );
    if (f != null) setState(() => _facility = f);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final f = _selectedFacility;
    final isDna = widget.serviceType == ServiceType.dnaTest;
    context.read<BookingsBloc>().add(
      CreateBookingEvent(
        CreateBookingParams(
          serviceType: widget.serviceType,
          serviceLabel: _label(context),
          dnaTestKind: isDna ? _dnaKind : null,
          clinicianTier: widget.serviceType == ServiceType.secondOpinion
              ? _tier
              : null,
          preferredLawFirm: isDna && _dnaKind == 'legal'
              ? _lawFirm.text.trim()
              : null,
          preferredDate: _date == null ? null : _fmtDate(_date!),
          preferredFacility: f?.name,
          facilityId: f?.id,
          referralId: widget.referral?.id,
          contactPhone: _normalizePhone(_phone.text),
          notes: _notes.text.trim(),
        ),
      ),
    );
  }

  void _retryPayment(ServiceBooking b) {
    context.read<BookingsBloc>().add(
      PushStkForBookingEvent(
        StkPushParams(
          bookingId: b.id,
          amountKes: b.priceKes,
          phone: b.contactPhone.isNotEmpty
              ? b.contactPhone
              : _normalizePhone(_phone.text),
          serviceTypeLabel: b.serviceLabel,
        ),
      ),
    );
  }

  void _afterPaymentStep(BookingsBloc bloc) => bloc.add(
    _locked ? const AwaitBookingConsentEvent() : const FinishBookingFlowEvent(),
  );

  Future<void> _runShrConsent(BookingsBloc bloc) async {
    if (mounted) bloc.add(const FinishBookingFlowEvent());
  }

  void _onStateChanged(BuildContext context, BookingsState state) {
    final bloc = context.read<BookingsBloc>();
    switch (state.createStatus) {
      case CreateBookingStatus.created:
        final b = state.createdBooking!;
        if (b.needsImmediatePayment) {
          _retryPayment(b);
        } else {
          _afterPaymentStep(bloc);
        }
      case CreateBookingStatus.awaitingPayment:
        _afterPaymentStep(bloc);
      case CreateBookingStatus.awaitingConsent:
        _runShrConsent(bloc);
      case CreateBookingStatus.error:
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingsBloc, BookingsState>(
      listenWhen: (p, c) =>
          p.createStatus != c.createStatus || p.stkError != c.stkError,
      listener: _onStateChanged,
      builder: (context, state) {
        final paymentError =
            state.stkError != null && state.createdBooking != null;
        final done = state.createStatus == CreateBookingStatus.completed;
        final busy =
            !done &&
            !paymentError &&
            (state.createStatus == CreateBookingStatus.creating ||
                state.createStatus == CreateBookingStatus.created ||
                state.createStatus == CreateBookingStatus.awaitingPayment ||
                state.createStatus == CreateBookingStatus.awaitingConsent ||
                state.stkLoading);

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (_, _) => [
              CustomAppBar(title: _label(context), isHome: false),
            ],
            body: done
                ? _buildDone(state)
                : paymentError
                ? _buildPaymentError(state)
                : _buildForm(busy: busy),
          ),
          bottomNavigationBar: (!done && !paymentError)
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: AppPrimaryButton(
                      onPressed: busy ? null : _submit,
                      label: AppLocalizations.getString(
                        context,
                        'bookings.create.submit',
                      ),
                      isLoading: busy,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildForm({required bool busy}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final f = _selectedFacility;
    final isDna = widget.serviceType == ServiceType.dnaTest;
    final isSecondOpinion = widget.serviceType == ServiceType.secondOpinion;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          if (_fixedPrice != null) ...[
            _PriceCard(label: _fixedPrice!),
            const SizedBox(height: AppSpacing.lg),
          ],
          SectionLabel(
            AppLocalizations.getString(context, 'bookings.create.serviceLabel'),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isSecondOpinion)
            DropdownButtonFormField<String>(
              initialValue: _tier,
              decoration: InputDecoration(
                labelText: AppLocalizations.getString(
                  context,
                  'bookings.create.clinician',
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'gp',
                  child: Text(
                    AppLocalizations.getString(context, 'bookings.create.gp'),
                  ),
                ),
                DropdownMenuItem(
                  value: 'consultant',
                  child: Text(
                    AppLocalizations.getString(
                      context,
                      'bookings.create.consultant',
                    ),
                  ),
                ),
              ],
              onChanged: busy ? null : (v) => setState(() => _tier = v ?? 'gp'),
            ),
          if (isDna) ...[
            DropdownButtonFormField<String>(
              initialValue: _dnaKind,
              decoration: InputDecoration(
                labelText: AppLocalizations.getString(
                  context,
                  'bookings.create.testType',
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'health_risk',
                  child: Text(
                    AppLocalizations.getString(
                      context,
                      'bookings.create.healthRisk',
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'paternity',
                  child: Text(
                    AppLocalizations.getString(
                      context,
                      'bookings.create.paternity',
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'legal',
                  child: Text(
                    AppLocalizations.getString(
                      context,
                      'bookings.create.legal',
                    ),
                  ),
                ),
              ],
              onChanged: busy
                  ? null
                  : (v) => setState(() => _dnaKind = v ?? 'health_risk'),
            ),
            if (_dnaKind == 'legal') ...[
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _lawFirm,
                enabled: !busy,
                decoration: InputDecoration(
                  labelText: AppLocalizations.getString(
                    context,
                    'bookings.create.lawFirm',
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: AppSpacing.lg),
          SectionLabel(
            AppLocalizations.getString(
              context,
              'bookings.create.whenAndWhereLabel',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SelectableTile(
            icon: Icons.local_hospital_outlined,
            label: _locked
                ? AppLocalizations.getString(
                    context,
                    'bookings.create.facility',
                  )
                : AppLocalizations.getString(
                    context,
                    'bookings.create.facilityOptional',
                  ),
            value:
                f?.name ??
                AppLocalizations.getString(
                  context,
                  'bookings.create.facilityNotSelected',
                ),
            subtitle: (f == null || f.town.isEmpty) ? null : f.town,
            trailingIcon: _locked ? Icons.lock_outline : null,
            onTap: (_locked || busy) ? null : _pickFacility,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SelectableTile(
            icon: Icons.calendar_today_outlined,
            label: AppLocalizations.getString(
              context,
              'bookings.create.preferredDate',
            ),
            value: _date == null
                ? AppLocalizations.getString(
                    context,
                    'bookings.create.selectDate',
                  )
                : _fmtDate(_date!),
            onTap: busy ? null : _pickDate,
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionLabel(
            AppLocalizations.getString(context, 'bookings.create.contactLabel'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _phone,
            enabled: !busy,
            keyboardType: TextInputType.phone,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: _validatePhone,
            onChanged: (v) {
              _phoneValidatorDebounce.run(() {
                if (!mounted) return;
                final ok = _validatePhone(v) == null;
                if (ok != _phoneValid) setState(() => _phoneValid = ok);
              });
            },
            decoration: InputDecoration(
              labelText: AppLocalizations.getString(
                context,
                'bookings.create.phone',
              ),
              hintText: AppLocalizations.getString(
                context,
                'bookings.create.phoneHint',
              ),
              suffixIcon: _phoneValid
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: cs.primary,
                      size: 20,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _notes,
            enabled: !busy,
            maxLines: 3,
            maxLength: 1000,
            decoration: InputDecoration(
              labelText: AppLocalizations.getString(
                context,
                'bookings.create.notes',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentError(BookingsState state) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final b = state.createdBooking!;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Icon(Icons.error_outline_rounded, size: 44, color: cs.error),
        const SizedBox(height: AppSpacing.md),
        Text(
          AppLocalizations.getString(
            context,
            'bookings.create.paymentFailedTitle',
          ),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          state.stkError!,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppPrimaryButton(
          onPressed: () => _retryPayment(b),
          label: AppLocalizations.getString(
            context,
            'bookings.create.retryPayment',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => context.router.maybePop(),
          child: Text(
            AppLocalizations.getString(context, 'bookings.create.payLater'),
          ),
        ),
      ],
    );
  }

  Widget _buildDone(BookingsState state) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final paid = state.stkResult != null;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.xl),
        Icon(Icons.check_circle_rounded, size: 64, color: cs.primary),
        const SizedBox(height: AppSpacing.md),
        Text(
          AppLocalizations.getString(context, 'bookings.create.doneTitle'),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          paid
              ? AppLocalizations.getString(
                  context,
                  'bookings.create.donePaidBody',
                )
              : AppLocalizations.getString(
                  context,
                  'bookings.create.doneUnpaidBody',
                ),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppPrimaryButton(
          onPressed: () => context.router.maybePop(),
          label: AppLocalizations.getString(context, 'bookings.create.done'),
        ),
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String label;
  const _PriceCard({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.payments_outlined, size: 20, color: cs.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              AppLocalizations.getString(context, 'bookings.create.priceLabel'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const _SelectableTile({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: cs.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                trailingIcon ?? Icons.chevron_right_rounded,
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
