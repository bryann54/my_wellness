import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/vitals/domain/entities/appointment.dart';

part 'facility_model.g.dart';

@JsonSerializable()
class FacilityModel {
  final String id;
  final String name;
  final String? town;
  final String? county;

  @JsonKey(name: 'keph_level')
  final int? kephLevel;

  @JsonKey(name: 'covers_sha')
  final bool coversSha;

  const FacilityModel({
    required this.id,
    required this.name,
    this.town,
    this.county,
    this.kephLevel,
    this.coversSha = false,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) =>
      _$FacilityModelFromJson(json);

  Map<String, dynamic> toJson() => _$FacilityModelToJson(this);

  Facility toEntity() => Facility(
    id: id,
    name: name,
    town: town,
    county: county,
    kephLevel: kephLevel,
    coversSha: coversSha,
  );
}
