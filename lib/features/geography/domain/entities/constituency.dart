import 'package:equatable/equatable.dart';

class Constituency extends Equatable {
  final int id;
  final String name;
  final int countyId;

  const Constituency({
    required this.id,
    required this.name,
    required this.countyId,
  });

  @override
  List<Object?> get props => [id, name, countyId];
}
