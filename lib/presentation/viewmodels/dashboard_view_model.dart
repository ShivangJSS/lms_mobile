import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/providers.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/dashboard_tip.dart';
import 'language_view_model.dart';

class DashboardState {
  final bool isLoading;
  final String? error;
  final DashboardStats? stats;
  final List<DashboardTip> tips;

  DashboardState({
    this.isLoading = false,
    this.error,
    this.stats,
    this.tips = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    DashboardStats? stats,
    List<DashboardTip>? tips,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
      tips: tips ?? this.tips,
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

      // The backend resolves the participant from the bearer token, so
      // there is no need to fetch the current user first.
      final stats = await repository.getDashboardStats();

      // Tips are decoration — a failure there must not blank the dashboard.
      List<DashboardTip> tips = const [];

      try {
        tips = await repository.getTips(
          languageId: ref.read(languageProvider).languageId,
        );
      } catch (_) {}

      state = state.copyWith(
        isLoading: false,
        stats: stats,
        tips: tips,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _messageFor(e),
      );
    } on SocketException {
      state = state.copyWith(
        isLoading: false,
        error: "No internet connection",
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  String _messageFor(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return "Your session has expired. Please log in again.";

      case 404:
        return "Participant not found.";

      case 500:
        return "Server error. Please try again.";

      default:
        return e.message ?? "Could not load your dashboard";
    }
  }
}

final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>(
  (ref) => DashboardViewModel(ref),
);
