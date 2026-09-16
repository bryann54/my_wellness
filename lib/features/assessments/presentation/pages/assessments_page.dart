import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessment_bloc.dart';

class AssessmentsPage extends StatelessWidget {
  const AssessmentsPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => AssessmentBloc(),
        child: Scaffold(
          appBar: AppBar(title: const Text('Assessments')),
          body: const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
                'Approved, versioned assessment definitions and server-owned results are required before any questionnaire can be shown or submitted.'),
          ),
        ),
      );
}
