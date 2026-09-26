import 'package:equatable/equatable.dart';

class VitalsAccess extends Equatable {
  final bool hasAccess;
  const VitalsAccess({required this.hasAccess});

  @override
  List<Object?> get props => [hasAccess];
}
