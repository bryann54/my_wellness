part of 'geography_bloc.dart';

abstract class GeographyEvent extends Equatable {
  const GeographyEvent();

  @override
  List<Object?> get props => [];
}

class LoadCountiesEvent extends GeographyEvent {
  const LoadCountiesEvent();
}

class LoadSubCountiesEvent extends GeographyEvent {
  const LoadSubCountiesEvent();
}

class LoadConstituenciesEvent extends GeographyEvent {
  const LoadConstituenciesEvent();
}

class LoadWardsEvent extends GeographyEvent {
  const LoadWardsEvent();
}

class LoadAllGeographyEvent extends GeographyEvent {
  const LoadAllGeographyEvent();
}
