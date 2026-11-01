import 'package:equatable/equatable.dart';

class Facility extends Equatable {
  final String id;
  final String name;
  final String town;
  final String county;
  final String address;
  final String phone;
  final List<String> services;
  final double? latitude;
  final double? longitude;
  final bool coversSha;
  final int? kephLevel;
  final List<String> shaFunds;
  final double? distanceKm;

  const Facility({
    required this.id,
    required this.name,
    this.town = '',
    this.county = '',
    this.address = '',
    this.phone = '',
    this.services = const [],
    this.latitude,
    this.longitude,
    this.coversSha = false,
    this.kephLevel,
    this.shaFunds = const [],
    this.distanceKm,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    town,
    county,
    address,
    phone,
    services,
    latitude,
    longitude,
    coversSha,
    kephLevel,
    shaFunds,
    distanceKm,
  ];
}
