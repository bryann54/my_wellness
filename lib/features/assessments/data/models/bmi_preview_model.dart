import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/assessments/domain/entities/bmi_preview.dart';

part 'bmi_preview_model.g.dart';

@JsonSerializable()
class BmiPreviewModel {
  final num bmi;
  final String classification;

  @JsonKey(name: 'deficit_kg')
  final num deficitKg;

  const BmiPreviewModel({
    required this.bmi,
    required this.classification,
    required this.deficitKg,
  });

  factory BmiPreviewModel.fromJson(Map<String, dynamic> json) =>
      _$BmiPreviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$BmiPreviewModelToJson(this);

  BmiPreview toEntity() => BmiPreview(
    bmi: bmi.toDouble(),
    classification: classification,
    deficitKg: deficitKg.toDouble(),
  );
}
