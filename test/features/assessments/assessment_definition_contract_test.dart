import 'package:flutter_test/flutter_test.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/features/assessments/data/models/assessment_definition_model.dart';

void main() {
  group('assessment definition contract', () {
    test('uses the normalized detail endpoint', () {
      expect(
        ApiEndpoints.assessmentDetail('endometriosis'),
        '/api/assessments/endometriosis/',
      );
      expect(
        ApiEndpoints.assessmentOffline('endometriosis'),
        isNot(ApiEndpoints.assessmentDetail('endometriosis')),
      );
    });

    test('decodes the normalized definition shape used by special flows', () {
      final definition = AssessmentDefinitionModel.fromJson({
        'slug': 'endometriosis',
        'category': 'Reproductive health',
        'title': 'Endometriosis Health Check',
        'short_title': 'Endometriosis',
        'tagline': 'Understand your symptoms',
        'before_you_begin': const [],
        'questions': [
          {
            'key': 'S1',
            'index': 0,
            'section': 'Safety',
            'prompt': 'Safety question',
            'type': 'radio',
            'options': [
              {'value': 'no', 'label': 'No'},
              {'value': 'yes', 'label': 'Yes'},
            ],
          },
        ],
        'ctas': const [],
      }).toEntity();

      expect(definition.slug, 'endometriosis');
      expect(definition.category, 'Reproductive health');
      expect(definition.questions, hasLength(1));
      expect(definition.questions.single.key, 'S1');
    });

    test('tolerates nullable definition display metadata', () {
      final definition = AssessmentDefinitionModel.fromJson({
        'slug': 'wellness-check',
        'category': null,
        'title': null,
        'short_title': null,
        'tagline': null,
        'questions': const [],
        'ctas': const [],
      }).toEntity();

      expect(definition.category, isEmpty);
      expect(definition.title, 'wellness-check');
      expect(definition.shortTitle, 'wellness-check');
      expect(definition.tagline, isEmpty);
    });

    test('decodes contract intro pages and encouraging-fact text', () {
      final definition = AssessmentDefinitionModel.fromJson({
        'slug': 'breast-cancer',
        'category': 'Cancer',
        'title': 'Breast cancer assessment',
        'short_title': 'Breast cancer',
        'tagline': 'Know your risk',
        'before_you_begin': [
          {'heading': 'Before you begin', 'body': 'Have your details ready.'},
          {'heading': '', 'body': ''},
          'invalid legacy item',
        ],
        'encouraging_fact': const {
          'emoji': 'heart',
          'text': 'Screening can find changes early.',
        },
        'questions': const [],
        'ctas': const [],
      }).toEntity();

      expect(definition.beforeYouBegin, hasLength(1));
      expect(definition.beforeYouBegin.single.heading, 'Before you begin');
      expect(definition.encouragingFact, 'Screening can find changes early.');
    });

    test('rejects legacy non-list intro content without crashing', () {
      final definition = AssessmentDefinitionModel.fromJson({
        'slug': 'legacy',
        'category': null,
        'title': null,
        'short_title': null,
        'tagline': null,
        'before_you_begin': const {'heading': 'Legacy', 'body': 'Shape'},
        'questions': const [],
        'ctas': const [],
      }).toEntity();

      expect(definition.beforeYouBegin, isEmpty);
      expect(definition.title, 'legacy');
    });
  });
}
