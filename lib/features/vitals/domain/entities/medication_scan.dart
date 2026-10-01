import 'package:equatable/equatable.dart';

class MedicationCandidateOption extends Equatable {
  final String id;
  final String name;
  final String? dosage;
  final String? frequency;

  const MedicationCandidateOption({
    required this.id,
    required this.name,
    this.dosage,
    this.frequency,
  });

  @override
  List<Object?> get props => [id, name, dosage, frequency];
}

class MedicationCandidate extends Equatable {
  final String? rawName;
  final String? name;
  final String? dosage;
  final String? frequency;
  final String? notes;
  final List<MedicationCandidateOption> candidates;

  const MedicationCandidate({
    this.rawName,
    this.name,
    this.dosage,
    this.frequency,
    this.notes,
    this.candidates = const [],
  });

  @override
  List<Object?> get props => [
    rawName,
    name,
    dosage,
    frequency,
    notes,
    candidates,
  ];
}

class MedicationScanResult extends Equatable {
  final List<MedicationCandidate> confirmed;
  final List<MedicationCandidate> needsConfirmation;
  final String? message;

  const MedicationScanResult({
    this.confirmed = const [],
    this.needsConfirmation = const [],
    this.message,
  });

  MedicationCandidate? get firstConfirmed =>
      confirmed.isEmpty ? null : confirmed.first;

  @override
  List<Object?> get props => [confirmed, needsConfirmation, message];
}
