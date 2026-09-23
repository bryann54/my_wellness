import 'package:equatable/equatable.dart';

class BpReading extends Equatable {
  final String id;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String? pulseClassification;

  /// Server stores this as a string decimal, e.g. "-77.94".
  final String? weightKg;

  /// 'blue' | 'green' | 'yellow' | 'orange' | 'red' — server-classified.
  final String classification;

  /// 'pre' | 'intra' | 'post' — dialysis context, optional.
  final String? dialysisPhase;

  final String takenAt; // ISO timestamp
  final String? notes;
  final String createdAt;

  const BpReading({
    required this.id,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.pulseClassification,
    this.weightKg,
    required this.classification,
    this.dialysisPhase,
    required this.takenAt,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    systolic,
    diastolic,
    pulse,
    pulseClassification,
    weightKg,
    classification,
    dialysisPhase,
    takenAt,
    notes,
    createdAt,
  ];
}
