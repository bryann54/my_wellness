import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/geography/domain/entities/constituency.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';
import 'package:my_wellness/features/geography/domain/entities/ward.dart';
import 'package:my_wellness/features/geography/domain/usecases/get_constituencies_usecase.dart';
import 'package:my_wellness/features/geography/domain/usecases/get_counties_usecase.dart';
import 'package:my_wellness/features/geography/domain/usecases/get_sub_counties_usecase.dart';
import 'package:my_wellness/features/geography/domain/usecases/get_wards_usecase.dart';

part 'geography_event.dart';
part 'geography_state.dart';

@injectable
class GeographyBloc extends Bloc<GeographyEvent, GeographyState> {
  final GetCountiesUseCase _getCounties;
  final GetSubCountiesUseCase _getSubCounties;
  final GetConstituenciesUseCase _getConstituencies;
  final GetWardsUseCase _getWards;

  GeographyBloc(
    this._getCounties,
    this._getSubCounties,
    this._getConstituencies,
    this._getWards,
  ) : super(const GeographyState()) {
    on<LoadCountiesEvent>(_onLoadCounties);
    on<LoadSubCountiesEvent>(_onLoadSubCounties);
    on<LoadConstituenciesEvent>(_onLoadConstituencies);
    on<LoadWardsEvent>(_onLoadWards);
    on<LoadAllGeographyEvent>(_onLoadAll);
  }

  Future<void> _onLoadCounties(
    LoadCountiesEvent event,
    Emitter<GeographyState> emit,
  ) async {
    if (state.counties.isNotEmpty) return; // already cached in state
    emit(state.copyWith(countiesStatus: LoadStatus.loading, clearError: true));
    final result = await _getCounties(NoParams());
    result.fold(
      (f) => emit(
        state.copyWith(
          countiesStatus: LoadStatus.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (list) => emit(
        state.copyWith(countiesStatus: LoadStatus.loaded, counties: list),
      ),
    );
  }

  Future<void> _onLoadSubCounties(
    LoadSubCountiesEvent event,
    Emitter<GeographyState> emit,
  ) async {
    if (state.subCounties.isNotEmpty) return;
    emit(
      state.copyWith(subCountiesStatus: LoadStatus.loading, clearError: true),
    );
    final result = await _getSubCounties(NoParams());
    result.fold(
      (f) => emit(
        state.copyWith(
          subCountiesStatus: LoadStatus.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (list) => emit(
        state.copyWith(subCountiesStatus: LoadStatus.loaded, subCounties: list),
      ),
    );
  }

  Future<void> _onLoadConstituencies(
    LoadConstituenciesEvent event,
    Emitter<GeographyState> emit,
  ) async {
    if (state.constituencies.isNotEmpty) return;
    emit(
      state.copyWith(
        constituenciesStatus: LoadStatus.loading,
        clearError: true,
      ),
    );
    final result = await _getConstituencies(NoParams());
    result.fold(
      (f) => emit(
        state.copyWith(
          constituenciesStatus: LoadStatus.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (list) => emit(
        state.copyWith(
          constituenciesStatus: LoadStatus.loaded,
          constituencies: list,
        ),
      ),
    );
  }

  Future<void> _onLoadWards(
    LoadWardsEvent event,
    Emitter<GeographyState> emit,
  ) async {
    if (state.wards.isNotEmpty) return;
    emit(state.copyWith(wardsStatus: LoadStatus.loading, clearError: true));
    final result = await _getWards(NoParams());
    result.fold(
      (f) => emit(
        state.copyWith(
          wardsStatus: LoadStatus.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (list) =>
          emit(state.copyWith(wardsStatus: LoadStatus.loaded, wards: list)),
    );
  }

  Future<void> _onLoadAll(
    LoadAllGeographyEvent event,
    Emitter<GeographyState> emit,
  ) async {
    add(const LoadCountiesEvent());
    add(const LoadSubCountiesEvent());
    // Constituencies and wards are loaded lazily — only if a form needs them.
  }
}
