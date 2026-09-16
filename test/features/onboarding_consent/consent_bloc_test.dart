import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wellness/features/onboarding_consent/presentation/bloc/consent_bloc.dart';

void main() {
  blocTest<ConsentBloc, ConsentState>(
    'does not capture consent without an approved consent contract',
    build: ConsentBloc.new,
    act: (bloc) => bloc.add(const ConsentAcknowledged()),
    expect: () => [isA<ConsentContractUnavailable>()],
  );
}
