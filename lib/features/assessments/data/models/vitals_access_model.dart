import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/assessments/domain/entities/vitals_access.dart';

part 'vitals_access_model.g.dart';

@JsonSerializable()
class VitalsAccessModel {
  @JsonKey(name: 'has_access')
  final bool hasAccess;

  const VitalsAccessModel({required this.hasAccess});

  factory VitalsAccessModel.fromJson(Map<String, dynamic> json) =>
      _$VitalsAccessModelFromJson(json);

  Map<String, dynamic> toJson() => _$VitalsAccessModelToJson(this);

  VitalsAccess toEntity() => VitalsAccess(hasAccess: hasAccess);
}
