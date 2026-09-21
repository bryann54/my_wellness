// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/geography/domain/entities/constituency.dart';

part 'constituency_model.g.dart';

@JsonSerializable()
class ConstituencyModel {
  final int? id;
  final String? name;
  final int? county;

  const ConstituencyModel({this.id, this.name, this.county});

  factory ConstituencyModel.fromJson(Map<String, dynamic> json) =>
      _$ConstituencyModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConstituencyModelToJson(this);

  Constituency toEntity() =>
      Constituency(id: id ?? 0, name: name ?? '', countyId: county ?? 0);
}
