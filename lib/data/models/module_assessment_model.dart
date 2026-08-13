import '../../domain/entities/module_assessment.dart';

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double _toDouble(dynamic v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return 0.0;
}

class McqOptionModel extends McqOption {
  const McqOptionModel({required super.optionId, required super.optionText});

  factory McqOptionModel.fromJson(Map<String, dynamic> json) {
    return McqOptionModel(
      optionId: _toInt(json['option_id']) ?? 0,
      optionText: json['option_text'] as String? ?? '',
    );
  }
}

class McqQuestionModel extends McqQuestion {
  const McqQuestionModel({
    required super.mcqId,
    required super.questionTitle,
    required super.allowsMultiple,
    super.questionDescription,
    super.imageUrl,
    super.marks,
    super.options,
  });

  factory McqQuestionModel.fromJson(Map<String, dynamic> json) {
    final options = json['options'] as List<dynamic>? ?? [];

    return McqQuestionModel(
      mcqId: _toInt(json['mcq_id']) ?? 0,
      questionTitle: json['question_title'] as String? ?? '',
      questionDescription: json['question_description'] as String?,
      imageUrl: json['image_url'] as String?,
      marks: _toDouble(json['marks']),
      allowsMultiple: json['allows_multiple'] == true,
      options: options
          .map((e) => McqOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ModuleAssessmentModel extends ModuleAssessment {
  const ModuleAssessmentModel({
    required super.moduleId,
    required super.passPercentage,
    super.questions,
  });

  factory ModuleAssessmentModel.fromJson(Map<String, dynamic> json) {
    final questions = json['questions'] as List<dynamic>? ?? [];

    return ModuleAssessmentModel(
      moduleId: _toInt(json['module_id']) ?? 0,
      passPercentage: _toDouble(json['pass_percentage']),
      questions: questions
          .map((e) => McqQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AssessmentResultModel extends AssessmentResult {
  const AssessmentResultModel({
    required super.totalQuestions,
    required super.correctAnswers,
    required super.scorePercentage,
    required super.passPercentage,
    required super.passed,
    required super.moduleCompleted,
    super.nextModuleId,
    super.nextModuleName,
  });

  factory AssessmentResultModel.fromJson(Map<String, dynamic> json) {
    return AssessmentResultModel(
      totalQuestions: _toInt(json['total_questions']) ?? 0,
      correctAnswers: _toInt(json['correct_answers']) ?? 0,
      scorePercentage: _toDouble(json['score_percentage']),
      passPercentage: _toDouble(json['pass_percentage']),
      passed: json['passed'] == true,
      moduleCompleted: json['module_completed'] == true,
      nextModuleId: _toInt(json['next_module_id']),
      nextModuleName: json['next_module_name'] as String?,
    );
  }
}
