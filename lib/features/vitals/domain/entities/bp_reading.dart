import 'package:equatable/equatable.dart';

class BpReading extends Equatable {
  final String id;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String? pulseClassification;
  final String? classificationLabel;
  final String? weightKg;
  final String classification;
  final String? dialysisPhase;

  final String takenAt;
  final String? notes;
  final String createdAt;

  const BpReading({
    required this.id,
    required this.systolic,
    required this.diastolic,
    this.classificationLabel,
    this.pulse,
    this.pulseClassification,
    this.weightKg,
    required this.classification,
    this.dialysisPhase,
    required this.takenAt,
    this.notes,
    required this.createdAt,
  });

  /// Optimistic local construct for offline queue writes.
  factory BpReading.local(Map<String, dynamic> data) {
    return BpReading(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      systolic: int.tryParse('${data['systolic']}') ?? 0,
      diastolic: int.tryParse('${data['diastolic']}') ?? 0,
      pulse: int.tryParse('${data['pulse']}'),
      classification: 'neutral',
      takenAt: DateTime.now().toIso8601String(),
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    systolic,
    diastolic,
    pulse,
    classificationLabel,
    pulseClassification,
    weightKg,
    classification,
    dialysisPhase,
    takenAt,
    notes,
    createdAt,
  ];
}
