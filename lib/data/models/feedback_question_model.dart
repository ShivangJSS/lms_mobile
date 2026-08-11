import '../../domain/entities/feedback_question.dart';

class FeedbackQuestionModel extends FeedbackQuestion {
  const FeedbackQuestionModel({
    required super.id,
    required super.questionText,
    required super.questionType,
    required super.options,
  });

  factory FeedbackQuestionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return FeedbackQuestionModel(
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