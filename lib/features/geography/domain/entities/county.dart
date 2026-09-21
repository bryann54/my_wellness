import 'package:equatable/equatable.dart';

class County extends Equatable {
  final int id;
  final int code;
  final String name;

  const County({required this.id, required this.code, required this.name});

  @override
  List<Object?> get props => [id, code, name];
}
