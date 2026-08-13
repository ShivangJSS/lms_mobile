import 'package:equatable/equatable.dart';

class McqOption extends Equatable {
  final int optionId;
  final String optionText;

  const McqOption({required this.optionId, required this.optionText});

  @override
  List<Object?> get props => [optionId, optionText];
}

class McqQuestion extends Equatable {
  final int mcqId;
  final String questionTitle;
  final String? questionDescription;
  final String? imageUrl;
  final double marks;

  /// True when the question has more than one correct option.
  final bool allowsMultiple;

  final List<McqOption> options;

  const McqQuestion({
    required this.mcqId,
    required this.questionTitle,
    required this.allowsMultiple,
    this.questionDescription,
    this.imageUrl,
    this.marks = 1,
    this.options = const [],
  });

  @override
  List<Object?> get props => [
        mcqId,
        questionTitle,
        questionDescription,
        imageUrl,
        marks,
        allowsMultiple,
        options,
      ];
}

class ModuleAssessment extends Equatable {
  final int moduleId;
  final double passPercentage;
  final List<McqQuestion> questions;

  const ModuleAssessment({
    required this.moduleId,
    required this.passPercentage,
    this.questions = const [],
  });

  bool get isEmpty => questions.isEmpty;

  @override
  List<Object?> get props => [moduleId, passPercentage, questions];
}

class AssessmentResult extends Equatable {
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercentage;
  final double passPercentage;

  final bool passed;
  final bool moduleCompleted;

  final int? nextModuleId;
  final String? nextModuleName;

  const AssessmentResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.passPercentage,
    required this.passed,
    required this.moduleCompleted,
    this.nextModuleId,
    this.nextModuleName,
  });

  @override
  List<Object?> get props => [
        totalQuestions,
        correctAnswers,
        scorePercentage,
        passPercentage,
        passed,
        moduleCompleted,
        nextModuleId,
        nextModuleName,
      ];
}
