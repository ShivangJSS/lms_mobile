import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int modulesCompleted;
  final int totalModules;
  final double averageScore;
  final int timeInvestedMinutes;

  /// 0.0 to 1.0
  final double overallProgress;

  /// Assessment options the participant has selected so far. Used to tell
  /// "no attempts yet" apart from "scored zero".
  final int questionsAttempted;

  const DashboardStats({
    required this.modulesCompleted,
    required this.totalModules,
    required this.averageScore,
    required this.timeInvestedMinutes,
    required this.overallProgress,
    this.questionsAttempted = 0,
  });

  bool get hasAttempts => questionsAttempted > 0;

  @override
  List<Object?> get props => [
        modulesCompleted,
        totalModules,
        averageScore,
        timeInvestedMinutes,
        overallProgress,
        questionsAttempted,
      ];
}
