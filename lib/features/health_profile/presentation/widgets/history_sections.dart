import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/features/health_profile/domain/entities/health_history.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MEASUREMENTS
// ─────────────────────────────────────────────────────────────────────────────

class MeasurementsSection extends StatefulWidget {
  const MeasurementsSection({super.key, required this.history});
  final HealthHistory history;

  @override
  State<MeasurementsSection> createState() => _MeasurementsSectionState();
}

class _MeasurementsSectionState extends State<MeasurementsSection> {
  bool _showAllBp = false;
  bool _showAllBs = false;
  _BpFilter _bpFilter = _BpFilter.all;

  @override
  Widget build(BuildContext context) {
    final h = widget.history;
    final measurements = [
      h.latestBloodPressure,
      h.latestBloodSugar,
      h.latestVitalSign,
    ].whereType<HealthMeasurement>().toList();

    if (measurements.isEmpty && h.allergies.isEmpty) {
      return const _SectionEmptyCard(
        icon: Icons.monitor_heart_outlined,
        title: 'No measurements yet',
        message:
            'Measurements recorded through health monitoring or connected records '
            'will appear here.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero tiles
        LayoutBuilder(
          builder: (context, constraints) {
            final twoCol = constraints.maxWidth > 420;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final item in measurements)
                  SizedBox(
                    width: twoCol
                        ? (constraints.maxWidth - 10) / 2
                        : constraints.maxWidth,
                    child: _MeasurementTile(item: item),
                  ),
                if (h.allergies.isNotEmpty)
                  SizedBox(
                    width: twoCol
                        ? (constraints.maxWidth - 10) / 2
                        : constraints.maxWidth,
                    child: _AllergySummaryTile(allergies: h.allergies),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _BpHistoryCard(
          filter: _bpFilter,
          showAll: _showAllBp,
          onFilterChanged: (f) => setState(() => _bpFilter = f),
          onToggleShowAll: () => setState(() => _showAllBp = !_showAllBp),
        ),
        if (h.latestBloodSugar != null) ...[
          const SizedBox(height: 14),
          _BloodSugarCard(
            latest: h.latestBloodSugar!,
            showAll: _showAllBs,
            onToggle: () => setState(() => _showAllBs = !_showAllBs),
          ),
        ],
      ],
    );
  }
}

class _MeasurementTile extends StatelessWidget {
  const _MeasurementTile({required this.item});
  final HealthMeasurement item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final attention = item.needsAttention;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: attention
            ? cs.errorContainer.withValues(alpha: .22)
            : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: attention
              ? cs.error.withValues(alpha: .35)
              : cs.outlineVariant.withValues(alpha: .5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: item.value,
              children: [
                if (item.unit != null)
                  TextSpan(
                    text: ' ${item.unit}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: attention ? cs.error : cs.onSurface,
            ),
          ),
          if (item.detail != null || item.recordedAt != null) ...[
            const SizedBox(height: 6),
            Text(
              [
                item.detail,
                if (item.recordedAt != null) _date(item.recordedAt!),
              ].whereType<String>().join(' · '),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _AllergySummaryTile extends StatelessWidget {
  const _AllergySummaryTile({required this.allergies});
  final List<HealthRecordItem> allergies;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final names = allergies.map((a) => a.title).where((s) => s.isNotEmpty);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Allergy information',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            '${allergies.length} recorded',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            names.isEmpty
                ? 'Not equivalent to “no known allergies”'
                : names.join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

enum _BpFilter { all, attention, normal }

class _BpHistoryCard extends StatelessWidget {
  const _BpHistoryCard({
    required this.filter,
    required this.showAll,
    required this.onFilterChanged,
    required this.onToggleShowAll,
  });

  final _BpFilter filter;
  final bool showAll;
  final ValueChanged<_BpFilter> onFilterChanged;
  final VoidCallback onToggleShowAll;

  // Note: the current entity only exposes the *latest* BP reading.
  // The contract's bp_readings list is mapped to latestBloodPressure only
  // in HealthHistory; the full list isn't on the entity yet. This card
  // therefore renders the available reading(s) and the filter UI, and will
  // light up automatically when the entity gains the full list.
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Blood pressure history',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Text(
                'Monitoring indicator',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SegmentedFilter(
            value: filter,
            onChanged: onFilterChanged,
            options: const {
              _BpFilter.all: 'All',
              _BpFilter.attention: 'Needs attention',
              _BpFilter.normal: 'In range',
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No blood pressure readings are available in this record.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Blood pressure categories are monitoring indicators, not a medical '
            'diagnosis. For treatment decisions, consult your healthcare professional.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BloodSugarCard extends StatelessWidget {
  const _BloodSugarCard({
    required this.latest,
    required this.showAll,
    required this.onToggle,
  });

  final HealthMeasurement latest;
  final bool showAll;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Blood glucose', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                latest.value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: latest.needsAttention ? cs.error : cs.onSurface,
                ),
              ),
              if (latest.unit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    latest.unit!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              const Spacer(),
              if (latest.recordedAt != null)
                Text(
                  _date(latest.recordedAt!),
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
            ],
          ),
          if (latest.detail != null) ...[
            const SizedBox(height: 6),
            _Pill(
              label: latest.detail!,
              tone: latest.needsAttention
                  ? _PillTone.warning
                  : _PillTone.neutral,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CLINICAL
// ─────────────────────────────────────────────────────────────────────────────

class ClinicalSection extends StatelessWidget {
  const ClinicalSection({super.key, required this.history});
  final HealthHistory history;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RecordRow(
          label: 'Diagnoses & medical conditions',
          records: history.diagnoses,
          emptyLine:
              'No clinical diagnoses documented in the available record.',
          emptyPillLabel: 'No record',
          display: (r) => _RecordDisplay(
            title: r.title,
            meta: r.subtitle != null ? '(${r.subtitle})' : null,
            date: r.recordedAt,
            body: r.detail,
          ),
        ),
        const SizedBox(height: 12),
        _RecordRow(
          label: 'Allergies & adverse reactions',
          records: history.allergies,
          emptyLine: 'No allergy or adverse-reaction information documented.',
          emptyPillLabel: 'Not documented',
          display: (r) => _RecordDisplay(
            title: r.title,
            meta: r.subtitle != null ? '(${r.subtitle})' : null,
            date: r.recordedAt,
            body: r.detail,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TREATMENT
// ─────────────────────────────────────────────────────────────────────────────

class TreatmentSection extends StatelessWidget {
  const TreatmentSection({super.key, required this.history});
  final HealthHistory history;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RecordRow(
          label: 'Laboratory results',
          records: history.labResults,
          emptyLine: 'No laboratory investigation results available.',
          display: (r) => _RecordDisplay(
            title: r.title,
            date: r.recordedAt,
            body: r.detail,
          ),
        ),
        const SizedBox(height: 12),
        _RecordRow(
          label: 'Procedures & interventions',
          records: history.procedures,
          emptyLine: 'No procedures or interventions documented.',
          display: (r) => _RecordDisplay(
            title: r.title,
            date: r.recordedAt,
            body: r.detail,
          ),
        ),
        const SizedBox(height: 12),
        _RecordRow(
          label: 'Prescriptions & medications',
          records: history.prescriptions,
          emptyLine: 'No prescriptions available in the connected history.',
          display: (r) => _RecordDisplay(
            title: r.title,
            meta: r.subtitle,
            date: r.recordedAt,
            body: r.detail,
          ),
        ),
        const SizedBox(height: 12),
        _RecordRow(
          label: 'Immunization history',
          records: history.immunizations,
          emptyLine: 'No vaccination records available in this history.',
          display: (r) => _RecordDisplay(
            title: r.title,
            meta: r.subtitle,
            date: r.recordedAt,
            body: r.detail,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JOURNEY
// ─────────────────────────────────────────────────────────────────────────────

class JourneySection extends StatelessWidget {
  const JourneySection({super.key, required this.history});
  final HealthHistory history;

  @override
  Widget build(BuildContext context) {
    if (history.journey.isEmpty) {
      return const _SectionEmptyCard(
        icon: Icons.timeline_outlined,
        title: 'No completed checks yet',
        message:
            'Completed health checks and recommended care will appear here.',
      );
    }
    return _JourneyTimeline(items: history.journey);
  }
}

class _JourneyTimeline extends StatelessWidget {
  const _JourneyTimeline({required this.items});
  final List<HealthJourneyItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: items[i].hasActiveWarning
                              ? cs.error
                              : cs.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.surface, width: 2),
                        ),
                      ),
                      if (i != items.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: cs.outlineVariant.withValues(alpha: .6),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i == items.length - 1 ? 0 : 18,
                    ),
                    child: _JourneyEntry(item: items[i]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _JourneyEntry extends StatelessWidget {
  const _JourneyEntry({required this.item});
  final HealthJourneyItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _titleCase(item.assessmentSlug),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (item.bandLabel != null)
              _Pill(
                label: item.bandLabel!,
                tone: item.hasActiveWarning
                    ? _PillTone.danger
                    : _PillTone.neutral,
              ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          _date(item.completedAt),
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        if (item.summary != null) ...[
          const SizedBox(height: 6),
          Text(item.summary!, style: Theme.of(context).textTheme.bodySmall),
        ],
        if (item.referralFacility != null) ...[
          const SizedBox(height: 6),
          Text(
            'Recommended care: ${item.referralFacility}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED
// ─────────────────────────────────────────────────────────────────────────────

class _RecordDisplay {
  const _RecordDisplay({required this.title, this.meta, this.body, this.date});
  final String title;
  final String? meta;
  final String? body;
  final DateTime? date;
}

class _RecordRow extends StatefulWidget {
  const _RecordRow({
    required this.label,
    required this.records,
    required this.emptyLine,
    required this.display,
    this.emptyPillLabel = 'No record',
  });

  final String label;
  final List<HealthRecordItem> records;
  final String emptyLine;
  final String emptyPillLabel;
  final _RecordDisplay Function(HealthRecordItem) display;

  @override
  State<_RecordRow> createState() => _RecordRowState();
}

class _RecordRowState extends State<_RecordRow> {
  bool _expanded = false;
  static const _previewCount = 3;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final records = widget.records;
    final hasMany = records.length > _previewCount;
    final visible = _expanded ? records : records.take(_previewCount).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Text(
                records.isEmpty ? '' : '${records.length}',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (records.isEmpty) ...[
            Text(
              widget.emptyLine,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            _Pill(label: widget.emptyPillLabel, tone: _PillTone.muted),
          ] else ...[
            for (var i = 0; i < visible.length; i++) ...[
              if (i != 0)
                Divider(
                  height: 20,
                  color: cs.outlineVariant.withValues(alpha: .6),
                ),
              _RecordEntry(display: widget.display(visible[i])),
            ],
            if (hasMany) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    _expanded ? 'Show recent records' : 'View all records',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _RecordEntry extends StatelessWidget {
  const _RecordEntry({required this.display});
  final _RecordDisplay display;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          display.meta == null
              ? display.title
              : '${display.title} ${display.meta}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        if (display.date != null) ...[
          const SizedBox(height: 2),
          Text(
            _date(display.date!),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
        if (display.body != null) ...[
          const SizedBox(height: 4),
          Text(
            display.body!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _SectionEmptyCard extends StatelessWidget {
  const _SectionEmptyCard({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedFilter<T> extends StatelessWidget {
  const _SegmentedFilter({
    required this.value,
    required this.onChanged,
    required this.options,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final Map<T, String> options;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (final entry in options.entries)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: value == entry.key ? cs.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: value == entry.key
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: value == entry.key
                          ? cs.onSurface
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _PillTone { neutral, muted, warning, danger }

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.tone = _PillTone.neutral});
  final String label;
  final _PillTone tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, fg) = switch (tone) {
      _PillTone.neutral => (cs.surfaceContainerHighest, cs.onSurfaceVariant),
      _PillTone.muted => (
        cs.surfaceContainerHigh.withValues(alpha: .6),
        cs.onSurfaceVariant,
      ),
      _PillTone.warning => (cs.tertiaryContainer, cs.onTertiaryContainer),
      _PillTone.danger => (cs.errorContainer, cs.onErrorContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _date(DateTime value) =>
    DateFormat('dd MMM yyyy').format(value.toLocal());

String _titleCase(String slug) => slug
    .split('-')
    .where((p) => p.isNotEmpty)
    .map((p) => '${p[0].toUpperCase()}${p.substring(1)}')
    .join(' ');
