// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';

part 'sub_county_model.g.dart';

@JsonSerializable()
class SubCountyModel {
  final int? id;
  final int? code;
  final String? name;
  final int? county;

  const SubCountyModel({this.id, this.code, this.name, this.county});

  factory SubCountyModel.fromJson(Map<String, dynamic> json) =>
      _$SubCountyModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubCountyModelToJson(this);

  SubCounty toEntity() => SubCounty(
    id: id ?? 0,
    code: code ?? 0,
    name: name ?? '',
    countyId: county ?? 0,
  );
}
