import '../../domain/entities/assessment_question.dart';

class AssessmentQuestionModel extends AssessmentQuestion {
  const AssessmentQuestionModel({
    required super.id,
    required super.questionText,
    required super.questionType,
    required super.options,
  });

  factory AssessmentQuestionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AssessmentQuestionModel(
      id: json['id'] ?? '',
      questionText: json['questionText'] ?? '',
      questionType: json['questionType'] ?? 'single_choice',
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'questionType': questionType,
      'options': options,
    };
  }
}
