import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.modulesCompleted,
    required super.totalModules,
    required super.averageScore,
    required super.timeInvestedMinutes,
    required super.overallProgress,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      modulesCompleted: json['modulesCompleted'] as int,
      totalModules: json['totalModules'] as int,
      averageScore: (json['averageScore'] as num).toDouble(),
      timeInvestedMinutes: json['timeInvestedMinutes'] as int,
      overallProgress: (json['overallProgress'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modulesCompleted': modulesCompleted,
      'totalModules': totalModules,
      'averageScore': averageScore,
      'timeInvestedMinutes': timeInvestedMinutes,
      'overallProgress': overallProgress,
    };
  }
}
