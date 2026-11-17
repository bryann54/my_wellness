import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/health_profile/data/datasources/health_history_remote_datasource.dart';
import 'package:my_wellness/features/health_profile/data/repositories/health_history_repository_impl.dart';
import 'package:my_wellness/features/health_profile/domain/entities/health_history.dart';
import 'package:my_wellness/features/health_profile/presentation/widgets/history_sections.dart';

void main() {
  test(
    'medical history maps each contract collection to structured data',
    () async {
      final repository = HealthHistoryRepositoryImpl(
        _FakeHealthHistoryRemoteDataSource({
          'bp_attention_notice': 'Review this reading.',
          'bp_readings': [
            {
              'id': 'bp-1',
              'systolic': 142,
              'diastolic': 91,
              'pulse': 76,
              'monitor_band': 'red',
              'monitor_band_label': 'Above monitoring range',
              'needs_attention': true,
              'taken_at': '2026-11-16T08:00:00+03:00',
            },
          ],
          'bs_readings': [
            {
              'id': 'bs-1',
              'value': '5.80',
              'unit': 'mmol/L',
              'reading_type_label': 'Fasting test',
              'classification': 'green',
              'classification_label': 'Within monitoring range',
              'taken_at': '2026-11-16T07:00:00+03:00',
            },
          ],
          'vital_signs': [
            {
              'id': 'vital-1',
              'vital_type': 'heart_rate',
              'vital_type_label': 'Heart rate',
              'value': '67.00',
              'unit': '/min',
              'taken_at': '2026-11-15T09:00:00+03:00',
            },
          ],
          'diagnoses': [
            {
              'id': 'diagnosis-1',
              'condition': 'Hypertension',
              'severity': 'moderate',
              'created_at': '2026-11-14T09:00:00Z',
            },
          ],
          'allergies': [
            {
              'id': 'allergy-1',
              'allergen': 'Penicillin',
              'reaction': 'Rash',
              'created_at': '2026-11-13T09:00:00Z',
            },
          ],
          'lab_results': [
            {
              'id': 'lab-1',
              'test_name': 'HbA1c',
              'result_value': '6.1',
              'unit': '%',
              'interpretation': 'N',
              'interpretation_label': 'Normal',
              'status': 'final',
              'status_label': 'Final',
              'result_date': '2026-11-12',
            },
          ],
          'procedure_records': [
            {
              'id': 'procedure-1',
              'procedure_name': 'ECG',
              'performed_date': '2026-11-11',
            },
          ],
          'prescriptions': [
            {
              'id': 'prescription-1',
              'medication': 'Amlodipine',
              'dosage': '5 mg',
              'start_date': '2026-11-10',
            },
          ],
          'immunizations': [
            {
              'id': 'immunization-1',
              'vaccine_name': 'Influenza',
              'dose_number': '1',
              'status': 'completed',
              'occurrence_date': '2026-11-09',
            },
          ],
        }),
      );

      final result = await repository.load();
      final history = result.fold((failure) => throw failure, (value) => value);

      expect(history.bpAttentionNotice, 'Review this reading.');
      expect(history.latestBloodPressure?.systolic, 142);
      expect(history.latestBloodPressure?.needsAttention, isTrue);
      expect(history.latestBloodSugar?.readingTypeLabel, 'Fasting test');
      expect(history.vitalSigns.single.typeLabel, 'Heart rate');
      expect(history.diagnoses.single.condition, 'Hypertension');
      expect(history.allergies.single.reaction, 'Rash');
      expect(history.labResults.single.testName, 'HbA1c');
      expect(history.procedures.single.name, 'ECG');
      expect(history.prescriptions.single.medication, 'Amlodipine');
      expect(history.immunizations.single.vaccineName, 'Influenza');
    },
  );

  test(
    'missing contract collections render as structured empty sections',
    () async {
      final result = await HealthHistoryRepositoryImpl(
        _FakeHealthHistoryRemoteDataSource(const {}),
      ).load();
      final history = result.fold((failure) => throw failure, (value) => value);

      expect(history.isEmpty, isTrue);
      expect(history.latestBloodPressure, isNull);
      expect(history.latestBloodSugar, isNull);
    },
  );

  testWidgets('all three native sections fit a phone viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const history = HealthHistory(
      bloodPressureReadings: [
        BloodPressureRecord(
          id: 'bp-1',
          systolic: 120,
          diastolic: 80,
          pulse: 72,
          monitorBandLabel: 'Within range',
        ),
      ],
      bloodSugarReadings: [
        BloodSugarRecord(
          id: 'bs-1',
          value: '5.5',
          unit: 'mmol/L',
          readingTypeLabel: 'Fasting test',
        ),
      ],
      diagnoses: [
        DiagnosisRecord(id: 'diagnosis-1', condition: 'Hypertension'),
      ],
      labResults: [
        LabResultRecord(id: 'lab-1', testName: 'HbA1c', value: '6.1'),
      ],
    );

    for (final section in <Widget>[
      const MeasurementsSection(history: history),
      const ClinicalSection(history: history),
      const CareRecordsSection(history: history),
    ]) {
      await tester.pumpWidget(_LocalizedTestApp(child: section));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}

class _LocalizedTestApp extends StatelessWidget {
  const _LocalizedTestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: const Locale('en'),
    supportedLocales: const [Locale('en'), Locale('sw')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );
}

class _FakeHealthHistoryRemoteDataSource
    implements HealthHistoryRemoteDataSource {
  const _FakeHealthHistoryRemoteDataSource(this.response);

  final Map<String, dynamic> response;

  @override
  Future<Map<String, dynamic>> load() async => response;
}
