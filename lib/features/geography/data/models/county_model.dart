// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';

part 'county_model.g.dart';

@JsonSerializable()
class CountyModel {
  final int? id;
  final int? code;
  final String? name;

  const CountyModel({this.id, this.code, this.name});

  factory CountyModel.fromJson(Map<String, dynamic> json) =>
      _$CountyModelFromJson(json);

  Map<String, dynamic> toJson() => _$CountyModelToJson(this);

  County toEntity() => County(id: id ?? 0, code: code ?? 0, name: name ?? '');
}
