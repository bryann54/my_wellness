import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_findings.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_hero.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_next_step.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_footer.dart';
import 'package:my_wellness/features/bookings/domain/entities/facility.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart'
    show ServiceType;

class CompleteBody extends StatelessWidget {
  final String slug;
  final AssessmentScore score;
  final AssessmentSession? session;
  final Referral? referral;
  final String? categoryRaw;

  const CompleteBody({
    super.key,
    required this.slug,
    required this.score,
    required this.session,
    this.referral,
    this.categoryRaw,
  });

  Future<void> _book(BuildContext context) async {
    final r = referral;
    final f = r?.recommendedFacility;
    if (r == null || f == null) return;
    final router = context.router;

    if (r.status == 'booked' || r.status == 'completed') {
      await router.push(ReferralDetailRoute(referralId: r.id));
      return;
    }

    final created = await router.push<bool>(
      CreateBookingRoute(
        serviceType: ServiceType.referralVisit,
        referralId: r.id,
        serviceLabel: r.escalationCategoryDisplay ?? r.escalationCategory,
        lockedFacility: Facility(
          id: f.id,
          name: f.name,
          town: f.town ?? '',
          county: f.county ?? '',
          address: f.address ?? '',
          phone: f.phone ?? '',
          latitude: f.latitude,
          longitude: f.longitude,
          coversSha: f.coversSha,
          kephLevel: f.kephLevel,
          distanceKm: f.distanceKm,
        ),
      ),
    );
    if (created == true) {
      await router.push(ReferralDetailRoute(referralId: r.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            CompleteHero(
              reference: session?.referenceNumber,
              categoryRaw: categoryRaw,
            ),
            const SizedBox(height: 24),
            CompleteFindings(score: score),
            const SizedBox(height: 24),
            CompleteNextStep(
              referral: referral,
              onBook: referral?.recommendedFacility == null
                  ? null
                  : () => _book(context),
            ),
            const SizedBox(height: 32),
            CompleteFooter(
              onDashboard: () => context.router.popUntilRoot(),
              onTakeAnother: () =>
                  context.router.replace(const AssessmentsListRoute()),
              onRate: () {
                // TODO: open rating sheet
              },
            ),
          ],
        ),
      ),
    );
  }
}
