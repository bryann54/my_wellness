import 'package:flutter_test/flutter_test.dart';
import 'package:my_wellness/features/home/data/datasources/home_dashboard_remote_datasource.dart';
import 'package:my_wellness/features/home/domain/entities/dashboard_session.dart';

void main() {
  group('home health-check cards', () {
    test('keeps untouched assessments at zero percent', () {
      final cards = parseDashboardHealthChecks([
        {
          'id': 'assessment:hypertension',
          'family': 'metabolic',
          'name': 'Hypertension',
          'assessment_slug': 'hypertension',
          'session_id': null,
          'status': 'not_started',
          'progress': 0,
        },
      ]);

      expect(cards, hasLength(1));
      expect(cards.single.status, DashboardSessionStatus.notStarted);
      expect(cards.single.completionPercent, 0);
      expect(cards.single.sessionId, isNull);
    });

    test('recognises workplace wellbeing cards for profile filtering', () {
      const card = DashboardSession(
        id: 'assessment:corporate-wellbeing-1',
        assessmentSlug: 'corporate-wellbeing-1',
        title: 'Workplace Wellbeing check-in',
        family: 'workplace',
        currentIndex: 0,
        totalQuestions: 100,
        completionPercent: 0,
        status: DashboardSessionStatus.notStarted,
      );

      expect(card.isWorkplaceWellbeing, isTrue);
    });

    test('drops an in-progress card without a resumable session', () {
      final cards = parseDashboardHealthChecks([
        {
          'id': 'assessment:stress',
          'family': 'mental',
          'name': 'Stress',
          'assessment_slug': 'stress',
          'session_id': null,
          'status': 'in_progress',
          'progress': 25,
        },
      ]);

      expect(cards, isEmpty);
    });
  });
}
