import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_toast_listener.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_body.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_loading.dart';

@RoutePage()
class AssessmentCompleteScreen extends StatelessWidget {
  final String slug;
  const AssessmentCompleteScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AssessmentsBloc>(),
      child: AssessmentToastListener(
        child: _AssessmentCompleteBody(slug: slug),
      ),
    );
  }
}

class _AssessmentCompleteBody extends StatefulWidget {
  final String slug;
  const _AssessmentCompleteBody({required this.slug});

  @override
  State<_AssessmentCompleteBody> createState() =>
      _AssessmentCompleteBodyState();
}

class _AssessmentCompleteBodyState extends State<_AssessmentCompleteBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<AssessmentsBloc>();
      if (bloc.state.score == null || !bloc.state.completionHandled) {
        bloc.add(const FetchScoreEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AssessmentsBloc>().state;

    if (state.score == null) {
      return const CompleteLoading();
    }

    return CompleteBody(
      slug: widget.slug,
      score: state.score!,
      session: state.session,
      referral: state.referral,
      categoryRaw: state.definition?.category,
    );
  }
}
