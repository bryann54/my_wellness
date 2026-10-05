import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/common/widgets/custom_alert_dialog.dart';
import 'package:my_wellness/features/vitals/domain/entities/appointment.dart';

class AppointmentTile extends StatefulWidget {
  final Appointment appointment;
  final VoidCallback onDelete;

  const AppointmentTile({
    super.key,
    required this.appointment,
    required this.onDelete,
  });

  @override
  State<AppointmentTile> createState() => _AppointmentTileState();
}

class _AppointmentTileState extends State<AppointmentTile> {
  bool _expanded = false;

  Appointment get a => widget.appointment;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasNotes = a.notes?.trim().isNotEmpty == true;

    return Dismissible(
      key: ValueKey(a.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => widget.onDelete(),
      background: _DismissBackground(color: cs.error),
      child: _Card(
        onTap: hasNotes ? () => setState(() => _expanded = !_expanded) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CollapsedRow(
              appointment: a,
              expanded: _expanded,
              showChevron: hasNotes,
              cs: cs,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _expanded && hasNotes
                  ? _ExpandedNotes(notes: a.notes!, cs: cs)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final ok = await AppDialogs.ask(
      context,
      title: AppLocalizations.getString(
        context,
        'appointments.deleteConfirmTitle',
      ),
      message: AppLocalizations.getString(
        context,
        'appointments.deleteConfirmMessage',
      ),
      isDestructive: true,
    );
    return ok ?? false;
  }
}

class _CollapsedRow extends StatelessWidget {
  final Appointment appointment;
  final bool expanded;
  final bool showChevron;
  final ColorScheme cs;

  const _CollapsedRow({
    required this.appointment,
    required this.expanded,
    required this.showChevron,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final dt = parseDateTime(a.appointmentDate, a.appointmentTime);
    final dayLabel = dt != null ? friendlyDay(dt) : a.appointmentDate;
    final timeLabel = dt != null ? friendlyTime(dt) : a.appointmentTime;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: cs.onSurface,
                    ),
                    children: [
                      TextSpan(text: dayLabel),
                      TextSpan(
                        text: '  ·  $timeLabel',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (a.condition != null) ...[
                const SizedBox(width: 8),
                _ConditionPill(condition: a.condition!, cs: cs),
              ],
              if (showChevron) ...[
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: cs.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.local_hospital_outlined,
                  size: 18,
                  color: cs.onSurface.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.clinicName.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: cs.onSurface.withValues(alpha: 0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (a.facility != null &&
                        (a.facility!.locality.isNotEmpty ||
                            a.facility!.kephLevel != null)) ...[
                      const SizedBox(height: 2),
                      Text(
                        _facilitySubtitle(a.facility!),
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          height: 1.3,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _facilitySubtitle(Facility f) {
    final parts = <String>[
      if (f.locality.isNotEmpty) f.locality,
      if (f.kephLevel != null) 'KEPH ${f.kephLevel}',
      if (f.coversSha) 'SHA',
    ];
    return parts.join(' · ');
  }
}

class _ExpandedNotes extends StatelessWidget {
  final String notes;
  final ColorScheme cs;

  const _ExpandedNotes({required this.notes, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.getString(
              context,
              'appointments.notesLabel',
            ).toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              height: 1.6,
              color: cs.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConditionPill extends StatelessWidget {
  final String condition;
  final ColorScheme cs;

  const _ConditionPill({required this.condition, required this.cs});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (condition.toLowerCase()) {
      'hypertension' => ('Hypertension', const Color(0xFF2563EB)),
      'diabetes' => ('Diabetes', const Color(0xFFDC2626)),
      _ => (
        AppLocalizations.getString(context, 'condition.other'),
        cs.onSurface.withValues(alpha: 0.5),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: color,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _Card({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.textLight.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  final Color color;
  const _DismissBackground({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: Colors.white,
        size: 25,
      ),
    );
  }
}
