import 'dart:math' as math;

enum BmiCategory {
  belowReference,
  withinReference,
  aboveReference,
  wellAboveReference,
}

class BmiMeasurement {
  const BmiMeasurement({
    required this.weightKg,
    required this.heightCm,
    required this.bmi,
    required this.category,
    required this.referenceWeightLowKg,
    required this.referenceWeightHighKg,
    required this.weightDifferenceKg,
    required this.firstMilestoneKg,
  });

  final double weightKg;
  final double heightCm;
  final double bmi;
  final BmiCategory category;
  final double referenceWeightLowKg;
  final double referenceWeightHighKg;
  final double weightDifferenceKg;

  /// An illustrative first loss milestone, capped at the amount required to
  /// reach the upper reference weight. Zero outside the >=25 categories.
  final double firstMilestoneKg;

  static BmiMeasurement calculate({
    required double weightKg,
    required double heightCm,
  }) {
    if (!weightKg.isFinite || weightKg < 20 || weightKg > 400) {
      throw const FormatException('Weight must be between 20 and 400 kg.');
    }
    if (!heightCm.isFinite || heightCm < 100 || heightCm > 250) {
      throw const FormatException('Height must be between 100 and 250 cm.');
    }

    final heightM = heightCm / 100;
    final heightSquared = heightM * heightM;
    final bmi = weightKg / heightSquared;
    final low = 18.5 * heightSquared;
    final high = 24.9 * heightSquared;
    final difference = math.max(0, weightKg - high).toDouble();
    final milestone = bmi >= 25
        ? math.min(weightKg * 0.05, difference).toDouble()
        : 0.0;

    final category = switch (bmi) {
      < 18.5 => BmiCategory.belowReference,
      < 25 => BmiCategory.withinReference,
      < 30 => BmiCategory.aboveReference,
      _ => BmiCategory.wellAboveReference,
    };

    return BmiMeasurement(
      weightKg: weightKg,
      heightCm: heightCm,
      bmi: bmi,
      category: category,
      referenceWeightLowKg: low,
      referenceWeightHighKg: high,
      weightDifferenceKg: difference,
      firstMilestoneKg: milestone,
    );
  }
}
