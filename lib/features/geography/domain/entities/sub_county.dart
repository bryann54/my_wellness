import 'package:equatable/equatable.dart';

class SubCounty extends Equatable {
  final int id;
  final int code;
  final String name;
  final int countyId;

  const SubCounty({
    required this.id,
    required this.code,
    required this.name,
    required this.countyId,
  });

  @override
  List<Object?> get props => [id, code, name, countyId];
}
