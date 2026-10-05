// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_scan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationScanModel _$MedicationScanModelFromJson(
  Map<String, dynamic> json,
) => MedicationScanModel(
  medications:
      (json['medications'] as List<dynamic>?)
          ?.map(
            (e) => MedicationCandidateModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  needsConfirmation:
      (json['needs_confirmation'] as List<dynamic>?)
          ?.map(
            (e) => MedicationCandidateModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  message: json['message'] as String?,
);

Map<String, dynamic> _$MedicationScanModelToJson(
  MedicationScanModel instance,
) => <String, dynamic>{
  'medications': instance.medications.map((e) => e.toJson()).toList(),
  'needs_confirmation': instance.needsConfirmation
      .map((e) => e.toJson())
      .toList(),
  'message': instance.message,
};

MedicationCandidateModel _$MedicationCandidateModelFromJson(
  Map<String, dynamic> json,
) => MedicationCandidateModel(
  rawName: json['raw_name'] as String?,
  name: json['name'] as String?,
  dosage: json['dosage'] as String?,
  frequency: json['frequency'] as String?,
  notes: json['notes'] as String?,
  candidates:
      (json['candidates'] as List<dynamic>?)
          ?.map(
            (e) => MedicationCandidateOptionModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$MedicationCandidateModelToJson(
  MedicationCandidateModel instance,
) => <String, dynamic>{
  'raw_name': instance.rawName,
  'name': instance.name,
  'dosage': instance.dosage,
  'frequency': instance.frequency,
  'notes': instance.notes,
  'candidates': instance.candidates,
};

MedicationCandidateOptionModel _$MedicationCandidateOptionModelFromJson(
  Map<String, dynamic> json,
) => MedicationCandidateOptionModel(
  id: json['id'] as String,
  name: json['name'] as String,
  dosage: json['dosage'] as String?,
  frequency: json['frequency'] as String?,
);

Map<String, dynamic> _$MedicationCandidateOptionModelToJson(
  MedicationCandidateOptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'dosage': instance.dosage,
  'frequency': instance.frequency,
};
