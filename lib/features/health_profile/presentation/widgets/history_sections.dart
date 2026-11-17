import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/health_profile/domain/entities/health_history.dart';

class MeasurementsSection extends StatefulWidget {
  const MeasurementsSection({super.key, required this.history});

  final HealthHistory history;

  @override
  State<MeasurementsSection> createState() => _MeasurementsSectionState();
}

class _MeasurementsSectionState extends State<MeasurementsSection> {
  _BpFilter _bpFilter = _BpFilter.all;
  bool _showAllBp = false;
  bool _showAllBs = false;
  bool _showAllVitals = false;

  @override
  Widget build(BuildContext context) {
    final history = widget.history;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        _SectionIntro(
          title: _t(context, 'healthHistory.measurementsTitle'),
          subtitle: _t(context, 'healthHistory.measurementsSubtitle'),
        ),
        const SizedBox(height: AppSpacing.md),
        _MeasurementSummary(history: history),
        const SizedBox(height: AppSpacing.md),
        _BloodPressureCard(
          readings: history.bloodPressureReadings,
          attentionNotice: history.bpAttentionNotice,
          filter: _bpFilter,
          showAll: _showAllBp,
          onFilterChanged: (value) => setState(() {
            _bpFilter = value;
            _showAllBp = false;
          }),
          onToggleAll: () => setState(() => _showAllBp = !_showAllBp),
        ),
        const SizedBox(height: AppSpacing.md),
        _BloodSugarCard(
          readings: history.bloodSugarReadings,
          showAll: _showAllBs,
          onToggleAll: () => setState(() => _showAllBs = !_showAllBs),
        ),
        const SizedBox(height: AppSpacing.md),
        _VitalSignsCard(
          records: history.vitalSigns,
          showAll: _showAllVitals,
          onToggleAll: () => setState(() => _showAllVitals = !_showAllVitals),
        ),
      ],
    );
  }
}

class ClinicalSection extends StatelessWidget {
  const ClinicalSection({super.key, required this.history});

  final HealthHistory history;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.xl,
    ),
    children: [
      _SectionIntro(
        title: _t(context, 'healthHistory.clinicalTitle'),
        subtitle: _t(context, 'healthHistory.clinicalSubtitle'),
      ),
      const SizedBox(height: AppSpacing.md),
      _RecordGroup<DiagnosisRecord>(
        icon: Icons.health_and_safety_outlined,
        title: _t(context, 'healthHistory.diagnoses'),
        records: history.diagnoses,
        emptyMessage: _t(context, 'healthHistory.noDiagnoses'),
        itemBuilder: (context, record) => _RecordTile(
          title: record.condition,
          badge: record.severity,
          body: record.details,
          date: record.recordedAt,
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _RecordGroup<AllergyRecord>(
        icon: Icons.warning_amber_rounded,
        title: _t(context, 'healthHistory.allergies'),
        records: history.allergies,
        emptyMessage: _t(context, 'healthHistory.noAllergies'),
        emptyBadge: _t(context, 'healthHistory.notDocumented'),
        itemBuilder: (context, record) => _RecordTile(
          title: record.allergen,
          badge: record.severity,
          metadata: record.reaction == null
              ? null
              : _tp(context, 'healthHistory.reaction', {
                  'value': record.reaction!,
                }),
          body: record.notes,
          date: record.recordedAt,
        ),
      ),
    ],
  );
}

class CareRecordsSection extends StatelessWidget {
  const CareRecordsSection({super.key, required this.history});

  final HealthHistory history;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.xl,
    ),
    children: [
      _SectionIntro(
        title: _t(context, 'healthHistory.careTitle'),
        subtitle: _t(context, 'healthHistory.careSubtitle'),
      ),
      const SizedBox(height: AppSpacing.md),
      _RecordGroup<LabResultRecord>(
        icon: Icons.science_outlined,
        title: _t(context, 'healthHistory.labResults'),
        records: history.labResults,
        emptyMessage: _t(context, 'healthHistory.noLabResults'),
        itemBuilder: (context, record) => _LabResultTile(record: record),
      ),
      const SizedBox(height: AppSpacing.md),
      _RecordGroup<ProcedureRecord>(
        icon: Icons.medical_services_outlined,
        title: _t(context, 'healthHistory.procedures'),
        records: history.procedures,
        emptyMessage: _t(context, 'healthHistory.noProcedures'),
        itemBuilder: (context, record) => _RecordTile(
          title: record.name,
          body: record.notes,
          date: record.recordedAt,
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _RecordGroup<PrescriptionRecord>(
        icon: Icons.medication_outlined,
        title: _t(context, 'healthHistory.prescriptions'),
        records: history.prescriptions,
        emptyMessage: _t(context, 'healthHistory.noPrescriptions'),
        itemBuilder: (context, record) => _RecordTile(
          title: record.medication,
          badge: record.dosage,
          metadata: _prescriptionPeriod(context, record),
          body: record.instructions,
          date: record.recordedAt,
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _RecordGroup<ImmunizationRecord>(
        icon: Icons.vaccines_outlined,
        title: _t(context, 'healthHistory.immunizations'),
        records: history.immunizations,
        emptyMessage: _t(context, 'healthHistory.noImmunizations'),
        itemBuilder: (context, record) => _RecordTile(
          title: record.vaccineName,
          badge: record.doseNumber == null
              ? null
              : _tp(context, 'healthHistory.dose', {
                  'value': record.doseNumber!,
                }),
          secondaryBadge: _immunizationStatus(context, record.status),
          body: record.notes,
          date: record.recordedAt,
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      _Footnote(text: _t(context, 'healthHistory.noRecordFootnote')),
      const SizedBox(height: AppSpacing.sm),
      _Footnote(text: _t(context, 'healthHistory.disclaimer')),
    ],
  );
}

class _MeasurementSummary extends StatelessWidget {
  const _MeasurementSummary({required this.history});

  final HealthHistory history;

  @override
  Widget build(BuildContext context) {
    final bloodPressure = history.latestBloodPressure;
    final bloodSugar = history.latestBloodSugar;
    final allergies = history.allergies;
    return Column(
      children: [
        _SummaryTile(
          icon: Icons.monitor_heart_outlined,
          label: _t(context, 'healthHistory.latestBloodPressure'),
          value: bloodPressure == null
              ? _t(context, 'healthHistory.notRecorded')
              : _tp(context, 'healthHistory.bpValue', {
                  'systolic': '${bloodPressure.systolic ?? '—'}',
                  'diastolic': '${bloodPressure.diastolic ?? '—'}',
                }),
          detail: bloodPressure == null
              ? _t(context, 'healthHistory.noReadingAvailable')
              : _join([
                  _date(context, bloodPressure.takenAt),
                  bloodPressure.monitorBandLabel,
                ]),
          tone: bloodPressure?.monitorBand == 'red'
              ? _SummaryTone.alert
              : _SummaryTone.normal,
        ),
        const SizedBox(height: AppSpacing.sm),
        _SummaryTile(
          icon: Icons.water_drop_outlined,
          label: _t(context, 'healthHistory.latestBloodGlucose'),
          value: bloodSugar == null
              ? _t(context, 'healthHistory.notRecorded')
              : '${bloodSugar.value} ${bloodSugar.unit ?? '%'}'.trim(),
          detail: bloodSugar == null
              ? _t(context, 'healthHistory.noReadingAvailable')
              : bloodSugar.readingTypeLabel,
        ),
        const SizedBox(height: AppSpacing.sm),
        _SummaryTile(
          icon: Icons.warning_amber_rounded,
          label: _t(context, 'healthHistory.allergyInformation'),
          value: allergies.isEmpty
              ? _t(context, 'healthHistory.notRecorded')
              : _tp(context, 'healthHistory.recordedCount', {
                  'count': '${allergies.length}',
                }),
          detail: allergies.isEmpty
              ? _t(context, 'healthHistory.noKnownAllergiesCaution')
              : allergies.map((record) => record.allergen).join(', '),
        ),
      ],
    );
  }
}

class _BloodPressureCard extends StatelessWidget {
  const _BloodPressureCard({
    required this.readings,
    required this.attentionNotice,
    required this.filter,
    required this.showAll,
    required this.onFilterChanged,
    required this.onToggleAll,
  });

  final List<BloodPressureRecord> readings;
  final String? attentionNotice;
  final _BpFilter filter;
  final bool showAll;
  final ValueChanged<_BpFilter> onFilterChanged;
  final VoidCallback onToggleAll;

  @override
  Widget build(BuildContext context) {
    final filtered = switch (filter) {
      _BpFilter.all => readings,
      _BpFilter.attention =>
        readings
            .where((record) => record.needsAttention)
            .toList(growable: false),
      _BpFilter.inRange =>
        readings
            .where((record) => !record.needsAttention)
            .toList(growable: false),
    };
    final visible = showAll ? filtered : filtered.take(3).toList();
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.favorite_border_rounded,
            title: _t(context, 'healthHistory.bpHistory'),
            subtitle: _t(context, 'healthHistory.bpHistorySubtitle'),
            count: filtered.length,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final option in _BpFilter.values)
                ChoiceChip(
                  label: Text(_bpFilterLabel(context, option)),
                  selected: option == filter,
                  onSelected: (_) => onFilterChanged(option),
                ),
            ],
          ),
          if (attentionNotice != null) ...[
            const SizedBox(height: AppSpacing.md),
            _AttentionNotice(message: attentionNotice!),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (visible.isEmpty)
            _EmptyMessage(
              text: readings.isEmpty
                  ? _t(context, 'healthHistory.noBpReadings')
                  : _t(context, 'healthHistory.noBpFilterResults'),
            )
          else
            for (var index = 0; index < visible.length; index++) ...[
              if (index != 0) const Divider(height: AppSpacing.lg),
              _BloodPressureTile(record: visible[index]),
            ],
          if (filtered.length > 3) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onToggleAll,
              child: Text(
                _t(
                  context,
                  showAll
                      ? 'healthHistory.showRecentReadings'
                      : 'healthHistory.viewAllReadings',
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _Footnote(text: _t(context, 'healthHistory.bpFootnote')),
        ],
      ),
    );
  }
}

class _BloodSugarCard extends StatelessWidget {
  const _BloodSugarCard({
    required this.readings,
    required this.showAll,
    required this.onToggleAll,
  });

  final List<BloodSugarRecord> readings;
  final bool showAll;
  final VoidCallback onToggleAll;

  @override
  Widget build(BuildContext context) {
    final visible = showAll ? readings : readings.take(1).toList();
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.water_drop_outlined,
            title: _t(context, 'healthHistory.bloodGlucose'),
            count: readings.length,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (visible.isEmpty)
            _EmptyMessage(text: _t(context, 'healthHistory.noBsReadings'))
          else
            for (var index = 0; index < visible.length; index++) ...[
              if (index != 0) const Divider(height: AppSpacing.lg),
              _BloodSugarTile(record: visible[index]),
            ],
          if (readings.length > 1) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onToggleAll,
              child: Text(
                _t(
                  context,
                  showAll
                      ? 'healthHistory.showLatestReading'
                      : 'healthHistory.viewAllReadings',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VitalSignsCard extends StatelessWidget {
  const _VitalSignsCard({
    required this.records,
    required this.showAll,
    required this.onToggleAll,
  });

  final List<VitalSignRecord> records;
  final bool showAll;
  final VoidCallback onToggleAll;

  @override
  Widget build(BuildContext context) {
    final visible = showAll ? records : records.take(3).toList();
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.monitor_weight_outlined,
            title: _t(context, 'healthHistory.otherVitals'),
            count: records.length,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (visible.isEmpty)
            _EmptyMessage(text: _t(context, 'healthHistory.noOtherVitals'))
          else
            for (var index = 0; index < visible.length; index++) ...[
              if (index != 0) const Divider(height: AppSpacing.lg),
              _RecordTile(
                title: visible[index].typeLabel,
                metadata: '${visible[index].value} ${visible[index].unit ?? ''}'
                    .trim(),
                body: visible[index].notes,
                date: visible[index].takenAt,
              ),
            ],
          if (records.length > 3) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onToggleAll,
              child: Text(
                _t(
                  context,
                  showAll
                      ? 'healthHistory.showRecentRecords'
                      : 'healthHistory.viewAllRecords',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BloodPressureTile extends StatelessWidget {
  const _BloodPressureTile({required this.record});

  final BloodPressureRecord record;

  @override
  Widget build(BuildContext context) {
    final metadata = _join([
      _date(context, record.takenAt),
      record.pulse == null
          ? null
          : _tp(context, 'healthHistory.pulse', {'value': '${record.pulse}'}),
      _dialysisPhase(context, record.dialysisPhase),
    ]);
    return _RecordTile(
      title: _tp(context, 'healthHistory.bpValue', {
        'systolic': '${record.systolic ?? '—'}',
        'diastolic': '${record.diastolic ?? '—'}',
      }),
      badge: record.monitorBandLabel,
      badgeTone: record.monitorBand == 'red'
          ? _BadgeTone.danger
          : record.needsAttention
          ? _BadgeTone.warning
          : _BadgeTone.positive,
      metadata: metadata,
      body: record.notes,
    );
  }
}

class _BloodSugarTile extends StatelessWidget {
  const _BloodSugarTile({required this.record});

  final BloodSugarRecord record;

  @override
  Widget build(BuildContext context) {
    final notClassified = record.classification == 'not_classified';
    return _RecordTile(
      title: '${record.value} ${record.unit ?? '%'}'.trim(),
      badge: notClassified
          ? _t(context, 'healthHistory.notClassified')
          : record.classificationLabel,
      badgeTone: switch (record.classification) {
        'red' => _BadgeTone.danger,
        'green' ||
        'within_target_2h' ||
        'within_general_target' => _BadgeTone.positive,
        'not_classified' || 'timing_not_met' => _BadgeTone.neutral,
        _ => _BadgeTone.warning,
      },
      metadata: _join([
        _date(context, record.takenAt),
        record.readingTypeLabel,
      ]),
      body: _join([
        if (notClassified)
          _t(context, 'healthHistory.notClassifiedExplanation'),
        record.notes,
      ]),
    );
  }
}

class _LabResultTile extends StatelessWidget {
  const _LabResultTile({required this.record});

  final LabResultRecord record;

  @override
  Widget build(BuildContext context) {
    final specimen = record.specimenTypeLabel == null
        ? null
        : _tp(context, 'healthHistory.specimen', {
            'type': record.specimenTypeLabel!,
            'date': _date(context, record.specimenCollectedAt) ?? '',
          });
    return _RecordTile(
      title: record.testName,
      metadata: '${record.value} ${record.unit ?? ''}'.trim(),
      badge: record.interpretationLabel,
      badgeTone: record.interpretation == 'N'
          ? _BadgeTone.positive
          : _BadgeTone.danger,
      secondaryBadge: record.status == 'final' ? null : record.statusLabel,
      body: _join([
        if (record.referenceRange != null)
          _tp(context, 'healthHistory.referenceRange', {
            'value': record.referenceRange!,
          }),
        specimen,
        record.notes,
      ]),
      date: record.recordedAt,
    );
  }
}

class _RecordGroup<T> extends StatefulWidget {
  const _RecordGroup({
    required this.icon,
    required this.title,
    required this.records,
    required this.emptyMessage,
    required this.itemBuilder,
    this.emptyBadge,
  });

  final IconData icon;
  final String title;
  final List<T> records;
  final String emptyMessage;
  final String? emptyBadge;
  final Widget Function(BuildContext context, T record) itemBuilder;

  @override
  State<_RecordGroup<T>> createState() => _RecordGroupState<T>();
}

class _RecordGroupState<T> extends State<_RecordGroup<T>> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final visible = _showAll ? widget.records : widget.records.take(3).toList();
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: widget.icon,
            title: widget.title,
            count: widget.records.length,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (visible.isEmpty)
            _EmptyMessage(
              text: widget.emptyMessage,
              badge: widget.emptyBadge ?? _t(context, 'healthHistory.noRecord'),
            )
          else
            for (var index = 0; index < visible.length; index++) ...[
              if (index != 0) const Divider(height: AppSpacing.lg),
              widget.itemBuilder(context, visible[index]),
            ],
          if (widget.records.length > 3) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => setState(() => _showAll = !_showAll),
              child: Text(
                _t(
                  context,
                  _showAll
                      ? 'healthHistory.showRecentRecords'
                      : 'healthHistory.viewAllRecords',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.title,
    this.badge,
    this.secondaryBadge,
    this.badgeTone = _BadgeTone.neutral,
    this.metadata,
    this.body,
    this.date,
  });

  final String title;
  final String? badge;
  final String? secondaryBadge;
  final _BadgeTone badgeTone;
  final String? metadata;
  final String? body;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = _date(context, date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title.isEmpty
                    ? _t(context, 'healthHistory.notRecorded')
                    : title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (formattedDate != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(
                formattedDate,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        if (metadata != null && metadata!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            metadata!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (badge != null || secondaryBadge != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              if (badge != null) _Badge(label: badge!, tone: badgeTone),
              if (secondaryBadge != null)
                _Badge(label: secondaryBadge!, tone: _BadgeTone.neutral),
            ],
          ),
        ],
        if (body != null && body!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            body!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    this.detail,
    this.tone = _SummaryTone.normal,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? detail;
  final _SummaryTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = tone == _SummaryTone.alert ? cs.error : cs.primary;
    return _SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tone == _SummaryTone.alert ? cs.error : null,
                  ),
                ),
                if (detail != null && detail!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppSpacing.xs),
      Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.45,
        ),
      ),
    ],
  );
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.icon,
    required this.title,
    this.subtitle,
    this.count,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 22),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (count != null)
          _Badge(
            label: _tp(context, 'healthHistory.recordCount', {
              'count': '$count',
            }),
          ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

class _AttentionNotice extends StatelessWidget {
  const _AttentionNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: .3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _tp(context, 'healthHistory.attention', {'message': message}),
              style: TextStyle(color: cs.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.text, this.badge});

  final String text;
  final String? badge;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _Badge(label: badge!),
        ],
      ],
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.tone = _BadgeTone.neutral});

  final String label;
  final _BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (background, foreground) = switch (tone) {
      _BadgeTone.neutral => (cs.surfaceContainerHighest, cs.onSurfaceVariant),
      _BadgeTone.positive => (cs.secondaryContainer, cs.onSecondaryContainer),
      _BadgeTone.warning => (cs.tertiaryContainer, cs.onTertiaryContainer),
      _BadgeTone.danger => (cs.errorContainer, cs.onErrorContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Footnote extends StatelessWidget {
  const _Footnote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      height: 1.5,
    ),
  );
}

enum _BpFilter { all, attention, inRange }

enum _BadgeTone { neutral, positive, warning, danger }

enum _SummaryTone { normal, alert }

String _t(BuildContext context, String key) =>
    AppLocalizations.getString(context, key);

String _tp(BuildContext context, String key, Map<String, String> params) =>
    AppLocalizations.t(context, key, params);

String? _date(BuildContext context, DateTime? value) {
  if (value == null) return null;
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).format(value.toLocal());
}

String? _join(Iterable<String?> values) {
  final present = values.whereType<String>().where((value) => value.isNotEmpty);
  return present.isEmpty ? null : present.join(' · ');
}

String _bpFilterLabel(BuildContext context, _BpFilter filter) =>
    switch (filter) {
      _BpFilter.all => _t(context, 'healthHistory.allReadings'),
      _BpFilter.attention => _t(context, 'healthHistory.needsAttention'),
      _BpFilter.inRange => _t(context, 'healthHistory.withinRange'),
    };

String? _dialysisPhase(BuildContext context, String? phase) => switch (phase) {
  'pre' => _t(context, 'healthHistory.preDialysis'),
  'post' => _t(context, 'healthHistory.postDialysis'),
  _ => null,
};

String? _immunizationStatus(BuildContext context, String? status) =>
    switch (status) {
      null || '' || 'completed' => null,
      'entered-in-error' => _t(context, 'healthHistory.enteredInError'),
      'not-done' => _t(context, 'healthHistory.notDone'),
      _ => _t(context, 'healthHistory.statusUnavailable'),
    };

String? _prescriptionPeriod(BuildContext context, PrescriptionRecord record) {
  final start = _date(context, record.startDate);
  if (start == null) return null;
  final end = _date(context, record.endDate);
  return end == null
      ? _tp(context, 'healthHistory.fromOngoing', {'start': start})
      : _tp(context, 'healthHistory.fromUntil', {'start': start, 'end': end});
}
