import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_package.dart';
import 'package:my_wellness/features/pricing/domain/usecases/get_pricing_packages.dart';

part 'pricing_event.dart';
part 'pricing_state.dart';

@injectable
class PricingBloc extends Bloc<PricingEvent, PricingState> {
  final GetPricingPackagesUseCase _getPackages;

  PricingBloc(this._getPackages) : super(const PricingState()) {
    on<LoadPricingPackagesEvent>(_load);
  }

  Future<void> _load(
    LoadPricingPackagesEvent event,
    Emitter<PricingState> emit,
  ) async {
    emit(state.copyWith(status: PricingStatus.loading, clearError: true));
    final result = await _getPackages(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PricingStatus.error,
          errorMessage: mapFailure(failure),
        ),
      ),
      (packages) => emit(
        state.copyWith(status: PricingStatus.loaded, packages: packages),
      ),
    );
  }
}
