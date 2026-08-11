import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int modulesCompleted;
  final int totalModules;
  final double averageScore;
  final int timeInvestedMinutes;
  final double overallProgress;

  const DashboardStats({
    required this.modulesCompleted,
    required this.totalModules,
    required this.averageScore,
    required this.timeInvestedMinutes,
    required this.overallProgress,
  });

  @override
  List<Object?> get props => [
        modulesCompleted,
        totalModules,
        averageScore,
        timeInvestedMinutes,
        overallProgress,
      ];
}
