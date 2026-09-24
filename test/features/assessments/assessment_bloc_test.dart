import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wellness/features/assessment/presentation/bloc/assessment_bloc.dart';

void main() {
  blocTest<AssessmentBloc, AssessmentState>(
    'does not infer or render an assessment without an approved definition',
    build: AssessmentBloc.new,
    act: (bloc) => bloc.add(const AssessmentRequested()),
    expect: () => [isA<AssessmentCatalogueUnavailable>()],
  );
}
