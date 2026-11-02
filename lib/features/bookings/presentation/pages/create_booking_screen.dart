import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/soft_input.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/bookings/domain/entities/facility.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/domain/repositories/bookings_repository.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:my_wellness/features/bookings/presentation/utils/booking_labels.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_choice_tile.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_section_label.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_toast_listener.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/facility_picker_sheet.dart';

@RoutePage()
class CreateBookingScreen extends StatelessWidget {
  final ServiceType serviceType;
  final String? referralId;
  final Facility? lockedFacility;
  final String? serviceLabel;
  final bool followUp;

  const CreateBookingScreen({
    super.key,
    required this.serviceType,
    this.referralId,
    this.lockedFacility,
    this.serviceLabel,
    this.followUp = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<BookingsBloc>(),
      child: BookingsToastListener(
        child: _CreateBookingBody(
          serviceType: serviceType,
          referralId: referralId,
          lockedFacility: lockedFacility,
          serviceLabel: serviceLabel,
          followUp: followUp,
        ),
      ),
    );
  }
}

class _CreateBookingBody extends StatefulWidget {
  final ServiceType serviceType;
  final String? referralId;
  final Facility? lockedFacility;
  final String? serviceLabel;
  final bool followUp;

  const _CreateBookingBody({
    required this.serviceType,
    required this.referralId,
    required this.lockedFacility,
    required this.serviceLabel,
    required this.followUp,
  });

  @override
  State<_CreateBookingBody> createState() => _CreateBookingBodyState();
}

class _CreateBookingBodyState extends State<_CreateBookingBody> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  final _lawFirm = TextEditingController();
  Facility? _facility;
  DateTime? _date;
  String _dnaKind = 'health_risk';
  String _tier = 'gp';
  bool _submitted = false;
  bool _phonePrefilled = false;

  bool get _locked => widget.lockedFacility != null;
  Facility? get _selectedFacility => widget.lockedFacility ?? _facility;
  bool get _isReferral => widget.serviceType == ServiceType.referralVisit;

  @override
  void initState() {
    super.initState();
    context.read<BookingsBloc>().add(const ResetCreateBookingEvent());

    // Pre-fill the M-Pesa phone from the signed-in member. User can edit.
    final profile = context.read<AccountBloc>().state.profile;
    final prefill = _pickPrefillPhone(profile?.phone);
    if (prefill != null) {
      _phone.text = prefill;
      _phonePrefilled = true;
    }
  }

  /// Prefer the profile's phone; fall back to none. Never overwrite a
  /// number the user already typed (shouldn't happen in initState, but safe).
  String? _pickPrefillPhone(String? raw) {
    if (raw == null) return null;
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    if (digits.startsWith('254') && digits.length == 12) return digits;
    if (digits.startsWith('0') && digits.length == 10) {
      return '254${digits.substring(1)}';
    }
    if (digits.length == 9) return '254$digits';
    return null;
  }

  @override
  void dispose() {
    _phone.dispose();
    _notes.dispose();
    _lawFirm.dispose();
    super.dispose();
  }

  String get _apiLabel => switch (widget.serviceType) {
    ServiceType.referralVisit =>
      widget.followUp
          ? 'Follow-up — ${widget.serviceLabel ?? ''}'
          : (widget.serviceLabel ?? 'Referral visit'),
    ServiceType.secondOpinion =>
      _tier == 'consultant'
          ? 'Second opinion — Consultant review'
          : 'Second opinion — GP review',
    ServiceType.dnaTest => 'DNA test',
    ServiceType.navigator => 'Navigator',
    ServiceType.screening => 'Screening',
    ServiceType.checkup => 'Checkup',
    ServiceType.unknown => 'Booking',
  };

  int? get _fixedPrice => switch (widget.serviceType) {
    ServiceType.dnaTest => 1000,
    ServiceType.secondOpinion => _tier == 'consultant' ? 2500 : 1000,
    _ => null,
  };

  String _title(BuildContext context) {
    if (_isReferral) {
      return widget.followUp
          ? AppLocalizations.getString(
              context,
              'bookings.referral.bookFollowUp',
            )
          : (widget.serviceLabel ??
                AppLocalizations.getString(context, 'bookings.referral.book'));
    }
    return bookingServiceLabel(
      context,
      widget.serviceType,
      _apiLabel,
      clinicianTier: _tier,
    );
  }

  String _subtitle(BuildContext context) {
    final key = _isReferral
        ? 'bookings.referral.bookSub'
        : switch (widget.serviceType) {
            ServiceType.navigator => 'bookings.service.navigatorSub',
            ServiceType.screening => 'bookings.service.screeningSub',
            ServiceType.dnaTest => 'bookings.service.dnaTestSub',
            ServiceType.secondOpinion => 'bookings.service.secondOpinionSub',
            _ => 'bookings.subtitle',
          };
    return AppLocalizations.getString(context, key);
  }

  String _normalizePhone(String raw) {
    var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.startsWith('0')) d = '254${d.substring(1)}';
    if (RegExp(r'^[17]\d{8}$').hasMatch(d)) d = '254$d';
    return d;
  }

  String? _validatePhone(String? v) =>
      RegExp(r'^254[17]\d{8}$').hasMatch(_normalizePhone(v ?? ''))
      ? null
      : AppLocalizations.getString(context, 'bookings.form.phoneInvalid');

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
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _pickFacility() async {
    HapticFeedback.selectionClick();
    final f = await FacilityPickerSheet.show(
      context,
      serviceType: widget.serviceType,
    );
    if (f != null && mounted) setState(() => _facility = f);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) return;
    HapticFeedback.selectionClick();
    final f = _selectedFacility;
    final isDna = widget.serviceType == ServiceType.dnaTest;
    setState(() => _submitted = true);
    context.read<BookingsBloc>().add(
      CreateBookingEvent(
        CreateBookingParams(
          serviceType: widget.serviceType,
          serviceLabel: _apiLabel,
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
          referralId: widget.referralId,
          contactPhone: _normalizePhone(_phone.text),
          notes: _notes.text.trim(),
        ),
      ),
    );
  }

  void _pay(ServiceBooking b) {
    context.read<BookingsBloc>().add(
      PushStkForBookingEvent(
        StkPushParams(
          bookingId: b.id,
          amountKes: b.priceKes,
          phone: _normalizePhone(_phone.text),
          serviceTypeLabel: b.serviceLabel,
        ),
      ),
    );
  }

  void _afterPaymentStep(BookingsBloc bloc) => bloc.add(
    _locked ? const AwaitBookingConsentEvent() : const FinishBookingFlowEvent(),
  );

  Future<void> _runShrConsent(BookingsBloc bloc) async {
    if (!mounted) return;
    bloc.add(const FinishBookingFlowEvent());
  }

  void _onStatus(BuildContext context, BookingsState state) {
    if (!_submitted) return;
    final bloc = context.read<BookingsBloc>();
    switch (state.createStatus) {
      case CreateBookingStatus.created:
        {
          final b = state.createdBooking;
          if (b == null) return;
          if (b.needsImmediatePayment) {
            _pay(b);
          } else {
            _afterPaymentStep(bloc);
          }
        }
      case CreateBookingStatus.awaitingPayment:
        _afterPaymentStep(bloc);
      case CreateBookingStatus.awaitingConsent:
        unawaited(_runShrConsent(bloc));
      case CreateBookingStatus.error:
        setState(() => _submitted = false);
      case CreateBookingStatus.idle ||
          CreateBookingStatus.creating ||
          CreateBookingStatus.completed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingsBloc, BookingsState>(
      listenWhen: (p, c) => p.createStatus != c.createStatus,
      listener: _onStatus,
      builder: (context, state) {
        final cs = Theme.of(context).colorScheme;
        final done =
            _submitted && state.createStatus == CreateBookingStatus.completed;
        final paymentFailed =
            _submitted &&
            state.stkError != null &&
            state.createdBooking != null &&
            !state.stkLoading;
        final busy =
            _submitted &&
            !done &&
            !paymentFailed &&
            state.createStatus != CreateBookingStatus.error &&
            state.createStatus != CreateBookingStatus.idle;
        final showForm = !done && !paymentFailed && !busy;

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (_, _) => [
              CustomAppBar(title: _title(context), isHome: false),
            ],
            body: done
                ? _DoneView(paid: state.stkResult != null)
                : paymentFailed
                ? _PaymentFailedView(
                    message: state.stkError!,
                    onRetry: () => _pay(state.createdBooking!),
                  )
                : busy
                ? _BusyView(
                    message: AppLocalizations.getString(
                      context,
                      state.stkLoading
                          ? 'bookings.payment.sending'
                          : 'bookings.creating',
                    ),
                  )
                : _buildForm(context),
          ),
          bottomNavigationBar: showForm
              ? Container(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    MediaQuery.paddingOf(context).bottom + 12,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(
                      top: BorderSide(
                        color: cs.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  child: AppPrimaryButton(
                    onPressed: _submit,
                    label: AppLocalizations.getString(
                      context,
                      'bookings.form.submit',
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildForm(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final f = _selectedFacility;
    final price = _fixedPrice;
    String t(String key) => AppLocalizations.getString(context, key);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          24,
          AppSpacing.md,
          24,
          AppSpacing.lg,
        ),
        children: [
          Text(
            _subtitle(context),
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          if (price != null) ...[
            const SizedBox(height: AppSpacing.md - 4),
            Text(
              '${t('bookings.form.price')}: ${formatKes(context, price)}',
              style: tt.titleMedium?.copyWith(color: cs.primary),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (widget.serviceType == ServiceType.secondOpinion) ...[
            BookingSectionLabel(t('bookings.form.clinician')),
            const SizedBox(height: AppSpacing.sm),
            BookingChoiceTile(
              label: t('bookings.form.clinicianGp'),
              selected: _tier == 'gp',
              onTap: () => setState(() => _tier = 'gp'),
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            BookingChoiceTile(
              label: t('bookings.form.clinicianConsultant'),
              selected: _tier == 'consultant',
              onTap: () => setState(() => _tier = 'consultant'),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (widget.serviceType == ServiceType.dnaTest) ...[
            BookingSectionLabel(t('bookings.form.testType')),
            const SizedBox(height: AppSpacing.sm),
            for (final (value, key) in const [
              ('health_risk', 'testHealthRisk'),
              ('paternity', 'testPaternity'),
              ('legal', 'testLegal'),
            ]) ...[
              BookingChoiceTile(
                label: t('bookings.form.$key'),
                selected: _dnaKind == value,
                onTap: () => setState(() => _dnaKind = value),
              ),
              const SizedBox(height: AppSpacing.sm + 2),
            ],
            if (_dnaKind == 'legal') ...[
              SoftInput(
                controller: _lawFirm,
                label: t('bookings.form.lawFirm'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.sm),
          ],
          BookingSectionLabel(
            t(
              _locked
                  ? 'bookings.form.facility'
                  : 'bookings.form.facilityOptional',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PickerField(
            value: f?.name ?? t('bookings.form.facilityNotSelected'),
            subtitle: _locked
                ? t('bookings.form.facilityLocked')
                : (f != null && f.town.isNotEmpty ? f.town : null),
            isPlaceholder: f == null,
            icon: _locked
                ? Icons.lock_outline_rounded
                : Icons.local_hospital_outlined,
            onTap: _locked ? null : _pickFacility,
            onClear: !_locked && f != null
                ? () => setState(() => _facility = null)
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          BookingSectionLabel(t('bookings.form.date')),
          const SizedBox(height: AppSpacing.sm),
          _PickerField(
            value: _date == null
                ? t('bookings.form.dateSelect')
                : _fmtDate(_date!),
            isPlaceholder: _date == null,
            icon: Icons.event_outlined,
            onTap: _pickDate,
            onClear: _date != null ? () => setState(() => _date = null) : null,
          ),
          const SizedBox(height: AppSpacing.md),
          SoftInput(
            controller: _phone,
            label: t('bookings.form.phone'),
            hint: t('bookings.form.phoneHint'),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
            ],
            validator: _validatePhone,
          ),
          if (_phonePrefilled) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              t('bookings.form.phonePrefillNote'),
              style: tt.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _notes,
            maxLines: 3,
            maxLength: 1000,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: t('bookings.form.notes')),
          ),
        ],
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String value;
  final String? subtitle;
  final bool isPlaceholder;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const _PickerField({
    required this.value,
    required this.isPlaceholder,
    required this.icon,
    this.subtitle,
    this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color:
          Theme.of(context).inputDecorationTheme.fillColor ??
          cs.surfaceContainerLow,
      borderRadius: AppRadius.mdAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md - 2,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: cs.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: tt.bodyMedium?.copyWith(
                        color: isPlaceholder
                            ? cs.onSurface.withValues(alpha: 0.4)
                            : cs.onSurface,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                )
              else if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurface.withValues(alpha: 0.28),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusyView extends StatelessWidget {
  final String message;

  const _BusyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentFailedView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PaymentFailedView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.getString(
                context,
                'bookings.payment.failedTitle',
              ),
              textAlign: TextAlign.center,
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              onPressed: onRetry,
              label: AppLocalizations.getString(
                context,
                'bookings.payment.retry',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => context.router.maybePop<bool>(true),
              child: Text(
                AppLocalizations.getString(context, 'bookings.payment.later'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  final bool paid;

  const _DoneView({required this.paid});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, size: 34, color: cs.onPrimary),
            ),
            const SizedBox(height: AppSpacing.lg - 4),
            Text(
              AppLocalizations.getString(context, 'bookings.done.title'),
              style: tt.headlineSmall?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppLocalizations.getString(
                context,
                paid ? 'bookings.done.bodyPaid' : 'bookings.done.bodyFree',
              ),
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              onPressed: () => context.router.maybePop<bool>(true),
              label: AppLocalizations.getString(
                context,
                'bookings.done.action',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
