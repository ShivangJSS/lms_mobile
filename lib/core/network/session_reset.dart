import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/viewmodels/dashboard_view_model.dart';
import '../../presentation/viewmodels/feedback_view_model.dart';
import '../../presentation/viewmodels/module_topics_view_model.dart';
import '../../presentation/viewmodels/module_view_model.dart';

/// Throws away every provider holding one participant's data.
///
/// These are all plain StateNotifierProviders, so their state — including
/// answers already ticked on the feedback form — outlives a logout unless it
/// is discarded explicitly. Without this the next participant to sign in on
/// the same device saw the previous one's selections.
void resetParticipantState(WidgetRef ref) {
  ref.invalidate(feedbackViewModelProvider);
  ref.invalidate(dashboardViewModelProvider);
  ref.invalidate(moduleViewModelProvider);
  ref.invalidate(moduleTopicsViewModelProvider);
  ref.invalidate(bottomNavIndexProvider);
}

/// Same as [resetParticipantState] but callable from a Ref rather than a
/// WidgetRef, for use inside view models.
void resetParticipantStateFromRef(Ref ref) {
  ref.invalidate(feedbackViewModelProvider);
  ref.invalidate(dashboardViewModelProvider);
  ref.invalidate(moduleViewModelProvider);
  ref.invalidate(moduleTopicsViewModelProvider);
  ref.invalidate(bottomNavIndexProvider);
}
