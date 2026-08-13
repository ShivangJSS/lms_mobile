import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.modulesCompleted,
    required super.totalModules,
    required super.averageScore,
    required super.timeInvestedMinutes,
    required super.overallProgress,
    required super.questionsAttempted,
  });

  /// Keys match the snake_case payload of GET /mobile/dashboard/stats.
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      modulesCompleted: _toInt(json['modules_completed']),
      totalModules: _toInt(json['total_modules']),
      averageScore: _toDouble(json['average_score']),
      timeInvestedMinutes: _toInt(json['time_invested_minutes']),
      overallProgress: _toDouble(json['overall_progress']),
      questionsAttempted: _toInt(json['questions_attempted']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modules_completed': modulesCompleted,
      'total_modules': totalModules,
      'average_score': averageScore,
      'time_invested_minutes': timeInvestedMinutes,
      'overall_progress': overallProgress,
      'questions_attempted': questionsAttempted,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}
