// lib/features/notifications/presentation/widgets/notification_tile.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/features/notifications/domain/entities/app_notification.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const NotificationTile({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (icon, accent) = _visualsFor(notification.route, cs);
    final tappable = onTap != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: cs.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (notification.body.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.45,
                            color: cs.onSurface.withValues(alpha: 0.65),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        _relativeTime(notification.receivedAt),
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: cs.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                if (tappable) ...[
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: cs.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static (IconData, Color) _visualsFor(
    NotificationRoute route,
    ColorScheme cs,
  ) {
    return switch (route) {
      NotificationRouteAppointment() || NotificationRouteAppointments() => (
        Icons.event_available_rounded,
        const Color(0xFF2563EB),
      ),
      NotificationRouteMedications() => (
        Icons.medication_outlined,
        const Color(0xFF7C3AED),
      ),
      NotificationRouteAssessment() ||
      NotificationRouteAssessments() ||
      NotificationRouteAssessmentResult() => (
        Icons.assignment_outlined,
        const Color(0xFFD63384),
      ),
      NotificationRouteVitals() => (
        Icons.monitor_heart_outlined,
        const Color(0xFFDC2626),
      ),
      NotificationRouteAccount() => (
        Icons.person_outline_rounded,
        const Color(0xFF0EA5E9),
      ),
      NotificationRouteNone() => (Icons.notifications_none_rounded, cs.primary),
    };
  }

  static String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d ${d == 1 ? 'day' : 'days'} ago';
    }
    final w = (diff.inDays / 7).floor();
    return '$w ${w == 1 ? 'week' : 'weeks'} ago';
  }
}
