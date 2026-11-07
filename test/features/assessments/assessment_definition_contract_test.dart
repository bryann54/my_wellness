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
  });
}
