import 'package:equatable/equatable.dart';

class BmiPreview extends Equatable {
  final double bmi;
  final String classification;
  final double deficitKg;

  const BmiPreview({
    required this.bmi,
    required this.classification,
    required this.deficitKg,
  });

  @override
  List<Object?> get props => [bmi, classification, deficitKg];
}
