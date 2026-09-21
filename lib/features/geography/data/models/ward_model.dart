// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/geography/domain/entities/ward.dart';

part 'ward_model.g.dart';

@JsonSerializable()
class WardModel {
  final int? id;
  final String? name;
  final int? constituency;

  const WardModel({this.id, this.name, this.constituency});

  factory WardModel.fromJson(Map<String, dynamic> json) =>
      _$WardModelFromJson(json);

  Map<String, dynamic> toJson() => _$WardModelToJson(this);

  Ward toEntity() =>
      Ward(id: id ?? 0, name: name ?? '', constituencyId: constituency ?? 0);
}
