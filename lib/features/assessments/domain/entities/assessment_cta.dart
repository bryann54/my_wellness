import 'package:equatable/equatable.dart';

class AssessmentCta extends Equatable {
  final String key;
  final String label;
  final String? serviceType;
  final String? serviceLabel;
  final String? description;
  final int? priceKes;

  const AssessmentCta({
    required this.key,
    required this.label,
    this.serviceType,
    this.serviceLabel,
    this.description,
    this.priceKes,
  });

  @override
  List<Object?> get props => [
    key,
    label,
    serviceType,
    serviceLabel,
    description,
    priceKes,
  ];
}
