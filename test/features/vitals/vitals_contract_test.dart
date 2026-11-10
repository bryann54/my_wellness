import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
import 'package:my_wellness/features/account/data/models/health_profile_model.dart';
import 'package:my_wellness/features/vitals/data/models/bp_reading_model.dart';
import 'package:my_wellness/features/vitals/data/models/bs_reading_model.dart';
import 'package:my_wellness/features/vitals/domain/entities/bmi_measurement.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_capture_bloc.dart';

void main() {
  group('BMI contract', () {
    test('uses the exact reference category boundaries', () {
      BmiMeasurement at(double bmi) =>
          BmiMeasurement.calculate(weightKg: bmi * 4, heightCm: 200);

      expect(at(18.49).category, BmiCategory.belowReference);
      expect(at(18.5).category, BmiCategory.withinReference);
      expect(at(24.99).category, BmiCategory.withinReference);
      expect(at(25).category, BmiCategory.aboveReference);
      expect(at(29.99).category, BmiCategory.aboveReference);
      expect(at(30).category, BmiCategory.wellAboveReference);
    });

    test('calculates reference weights and caps the 5 percent milestone', () {
      final result = BmiMeasurement.calculate(weightKg: 102, heightCm: 190);

      expect(result.bmi, closeTo(28.2548, 0.0001));
      expect(result.referenceWeightLowKg, closeTo(66.785, 0.001));
      expect(result.referenceWeightHighKg, closeTo(89.889, 0.001));
      expect(result.weightDifferenceKg, closeTo(12.111, 0.001));
      expect(result.firstMilestoneKg, closeTo(5.1, 0.001));
    });

    test('enforces the contract input ranges', () {
      expect(
        () => BmiMeasurement.calculate(weightKg: 19.9, heightCm: 170),
        throwsFormatException,
      );
      expect(
        () => BmiMeasurement.calculate(weightKg: 70, heightCm: 99.9),
        throwsFormatException,
      );
      expect(
        () => BmiMeasurement.calculate(weightKg: 400.1, heightCm: 170),
        throwsFormatException,
      );
      expect(
        () => BmiMeasurement.calculate(weightKg: 70, heightCm: 250.1),
        throwsFormatException,
      );
    });
  });

  group('vitals pathway contract', () {
    test('provider plan is not a continuation requirement', () {
      const state = VitalsCaptureState(pathwayValue: 'routine');

      expect(state.needsProviderPlan, isFalse);
      expect(state.followupCanContinue, isTrue);
    });

    test('treatment gap is optional while dialysis days are required', () {
      const treatmentGap = VitalsCaptureState(
        pathwayValue: 'diagnosed_not_on_medication',
      );
      const dialysis = VitalsCaptureState(pathwayValue: 'kidney_dialysis');

      expect(treatmentGap.followupCanContinue, isTrue);
      expect(dialysis.followupCanContinue, isFalse);
      expect(
        dialysis.copyWith(dialysisDays: const [1]).followupCanContinue,
        isTrue,
      );
    });

    test('dialysis selection supports seven distinct weekdays', () {
      expect(toggleDialysisDaySelection(const [0, 1, 2], 3), [0, 1, 2, 3]);
      expect(toggleDialysisDaySelection(const [0, 1, 2], 1), [0, 2]);
      expect(toggleDialysisDaySelection(const [0, 1, 2, 3, 4, 5, 6], 3), [
        0,
        1,
        2,
        4,
        5,
        6,
      ]);
      expect(toggleDialysisDaySelection(const [0], 7), [0]);
    });
  });

  test('health profile reads the server BMI prompt flag', () {
    final profile = HealthProfileModel.fromJson({
      'email': 'person@example.com',
      'full_name': 'Person',
      'phone': '0700000000',
      'gender': 'female',
      'member_code': 'MW-1',
      'bmi_prompt_due': true,
    }).toEntity();

    expect(profile.bmiPromptDue, isTrue);
  });

  test('BP history model preserves actual server values and labels', () {
    final reading = BpReadingModel.fromJson({
      'id': 'reading-1',
      'systolic': 80,
      'diastolic': 80,
      'pulse': 90,
      'pulse_classification': 'green',
      'classification': 'blue',
      'classification_label': 'Low Blood Pressure',
      'weight_kg': '76.00',
      'dialysis_phase': '',
      'taken_at': '2026-11-07T10:25:52.238769+03:00',
      'notes': '',
      'created_at': '2026-11-07T10:25:52.239187+03:00',
    }).toEntity();

    expect(reading.systolic, 80);
    expect(reading.diastolic, 80);
    expect(reading.pulse, 90);
    expect(reading.classification, 'blue');
    expect(reading.classificationLabel, 'Low Blood Pressure');
  });

  test('BS history model preserves web reading context and labels', () {
    final reading = BsReadingModel.fromJson(const {
      'id': 'reading-1',
      'value': '13.20',
      'unit': 'mmol/L',
      'reading_type': 'post_meal',
      'meal_timing': 'at_least_2h',
      'classification': 'orange_1',
      'classification_label': 'High Blood Sugar',
      'weight_kg': '76.00',
      'taken_at': '2026-11-07T10:25:52.238769+03:00',
      'notes': '',
      'created_at': '2026-11-07T10:25:52.239187+03:00',
    }).toEntity();

    expect(reading.value, '13.20');
    expect(reading.unit, 'mmol/L');
    expect(reading.readingType, 'post_meal');
    expect(reading.mealTiming, 'at_least_2h');
    expect(reading.classification, 'orange_1');
    expect(reading.classificationLabel, 'High Blood Sugar');
  });

  testWidgets('latest-reading shimmer stays bounded like its parent card', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            child: ListView(children: const [ShimmerLatestCard()]),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final size = tester.getSize(find.byType(ShimmerLatestCard));
    expect(size.width, 390);
    expect(size.height, lessThan(220));
  });

  testWidgets('shared shimmer compositions stay bounded in scrolling parents', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            child: ListView(
              children: const [
                ShimmerParagraph(lines: 3),
                ShimmerListTile(),
                ShimmerCard(height: 88),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ShimmerListTile)).height, lessThan(100));
    expect(tester.getSize(find.byType(ShimmerCard)).height, 88);
  });
}
