part of 'geography_bloc.dart';
// part of 'geography_bloc.dart';

enum LoadStatus { idle, loading, loaded, error }

class GeographyState extends Equatable {
  final LoadStatus countiesStatus;
  final LoadStatus subCountiesStatus;
  final LoadStatus constituenciesStatus;
  final LoadStatus wardsStatus;

  final List<County> counties;
  final List<SubCounty> subCounties;
  final List<Constituency> constituencies;
  final List<Ward> wards;

  final String? errorMessage;

  const GeographyState({
    this.countiesStatus = LoadStatus.idle,
    this.subCountiesStatus = LoadStatus.idle,
    this.constituenciesStatus = LoadStatus.idle,
    this.wardsStatus = LoadStatus.idle,
    this.counties = const [],
    this.subCounties = const [],
    this.constituencies = const [],
    this.wards = const [],
    this.errorMessage,
  });

  /// Sub-counties belonging to a given county (Option A: client-side filter).
  List<SubCounty> subCountiesIn(int countyId) =>
      subCounties.where((s) => s.countyId == countyId).toList();

  /// Constituencies belonging to a given county (for the electoral branch).
  List<Constituency> constituenciesIn(int countyId) =>
      constituencies.where((c) => c.countyId == countyId).toList();

  /// Wards belonging to a given constituency.
  List<Ward> wardsIn(int constituencyId) =>
      wards.where((w) => w.constituencyId == constituencyId).toList();

  /// Nullable lookup — safe for form flows where "not found" must not
  /// silently produce a fake county with id 0.
  County? countyByIdOrNull(int id) {
    for (final c in counties) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Keep if other screens rely on it; otherwise delete.
  County? countyById(int id) => countyByIdOrNull(id);

  GeographyState copyWith({
    LoadStatus? countiesStatus,
    LoadStatus? subCountiesStatus,
    LoadStatus? constituenciesStatus,
    LoadStatus? wardsStatus,
    List<County>? counties,
    List<SubCounty>? subCounties,
    List<Constituency>? constituencies,
    List<Ward>? wards,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GeographyState(
      countiesStatus: countiesStatus ?? this.countiesStatus,
      subCountiesStatus: subCountiesStatus ?? this.subCountiesStatus,
      constituenciesStatus: constituenciesStatus ?? this.constituenciesStatus,
      wardsStatus: wardsStatus ?? this.wardsStatus,
      counties: counties ?? this.counties,
      subCounties: subCounties ?? this.subCounties,
      constituencies: constituencies ?? this.constituencies,
      wards: wards ?? this.wards,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    countiesStatus,
    subCountiesStatus,
    constituenciesStatus,
    wardsStatus,
    counties,
    subCounties,
    constituencies,
    wards,
    errorMessage,
  ];
}
