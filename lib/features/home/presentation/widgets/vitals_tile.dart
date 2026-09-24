import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';
import 'package:auto_route/auto_route.dart';

enum VitalsTileKind { bp, bs }

class VitalsTile extends StatelessWidget {
  final VitalsTileKind kind;
  const VitalsTile({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isBp = kind == VitalsTileKind.bp;

    return BlocBuilder<VitalsBloc, VitalsState>(
      buildWhen: (p, c) =>
          p.bpReadings != c.bpReadings || p.bsReadings != c.bsReadings,
      builder: (context, state) {
        final reading = isBp ? state.latestBp : state.latestBs;

        return InkWell(
          onTap: () =>
              context.router.push(VitalsRoute(initialTab: isBp ? 0 : 1)),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isBp ? const Color(0xFFEFF6FF) : const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isBp
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isBp ? Icons.favorite : Icons.water_drop,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.getString(
                              context,
                              isBp
                                  ? 'vitals.bloodPressure'
                                  : 'vitals.bloodSugar',
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            AppLocalizations.getString(
                              context,
                              isBp ? 'vitals.bpSubtitle' : 'vitals.bsSubtitle',
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (reading == null)
                  Text(
                    AppLocalizations.getString(
                      context,
                      'vitals.logFirstReading',
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        isBp
                            ? '${state.latestBp!.systolic}/${state.latestBp!.diastolic}'
                            : state.latestBs!.value,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isBp ? 'mmHg' : state.latestBs!.unit,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppLocalizations.getString(context, 'vitals.startTracking'),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isBp
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFDC2626),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
