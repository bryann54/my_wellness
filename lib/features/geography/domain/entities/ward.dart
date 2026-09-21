import 'package:equatable/equatable.dart';

class Ward extends Equatable {
  final int id;
  final String name;
  final int constituencyId;

  const Ward({
    required this.id,
    required this.name,
    required this.constituencyId,
  });

  @override
  List<Object?> get props => [id, name, constituencyId];
}
