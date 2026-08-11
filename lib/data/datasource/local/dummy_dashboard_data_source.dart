import '../../../data/models/dashboard_stats_model.dart';

class DummyDashboardDataSource {
  Future<DashboardStatsModel> getDashboardStats(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return dummy data matching the screenshot
    return const DashboardStatsModel(
      modulesCompleted: 2,
      totalModules: 8,
      averageScore: 25.0,
      timeInvestedMinutes: 0,
      overallProgress: 0.25, // 25%
    );
  }
}
