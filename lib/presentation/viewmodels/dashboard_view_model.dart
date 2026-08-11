import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/providers.dart';
import '../../domain/entities/dashboard_stats.dart';

class DashboardState {
  final bool isLoading;
  final String? error;
  final DashboardStats? stats;

  DashboardState({
    this.isLoading = false,
    this.error,
    this.stats,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    DashboardStats? stats,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
    );
  }
}

class DashboardViewModel extends StateNotifier<DashboardState> {
  final Ref ref;

  DashboardViewModel(this.ref) : super(DashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(dashboardRepositoryProvider);

      // Logged-in participant
      final authRepo = ref.read(authRepositoryProvider);
      final participant = await authRepo.getCurrentUser();

      final userId =
          participant?.participantId.toString() ?? '0';

      final stats = await repository.getDashboardStats(
        userId,
      );

      state = state.copyWith(
        isLoading: false,
        stats: stats,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final dashboardViewModelProvider =
StateNotifierProvider<DashboardViewModel, DashboardState>(
      (ref) => DashboardViewModel(ref),
);