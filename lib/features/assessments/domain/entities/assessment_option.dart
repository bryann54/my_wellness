import 'package:equatable/equatable.dart';

class AssessmentOption extends Equatable {
  final String value;
  final String label;
  const AssessmentOption({required this.value, required this.label});

  @override
  List<Object?> get props => [value, label];
}
