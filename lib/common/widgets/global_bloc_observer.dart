import 'package:flutter_bloc/flutter_bloc.dart';

/// Intentionally does not log events or states. Feature events and states may
/// contain identifiers, payment contact details, or sensitive health choices.
class AppGlobalBlocObserver extends BlocObserver {}
