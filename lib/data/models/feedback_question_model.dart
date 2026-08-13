import '../../domain/entities/feedback_question.dart';

class FeedbackOptionModel extends FeedbackOption {
  const FeedbackOptionModel({
    required super.optionId,
    required super.optionName,
    super.optionIcon,
  });

  factory FeedbackOptionModel.fromJson(Map<String, dynamic> json) {
    return FeedbackOptionModel(
      optionId: _toInt(json['option_id']) ?? 0,
      optionName: json['option_name'] as String? ?? '',
      optionIcon: json['option_icon'] as String?,
    );
  }
}

class FeedbackQuestionModel extends FeedbackQuestion {
  const FeedbackQuestionModel({
    required super.questionId,
    required super.questionName,
    required super.questionType,
    required super.languageId,
    super.questionDescription,
    super.options,
  });

  factory FeedbackQuestionModel.fromJson(Map<String, dynamic> json) {
    final options = json['options'] as List<dynamic>? ?? [];

    return FeedbackQuestionModel(
      questionId: _toInt(json['question_id']) ?? 0,
      questionName: json['question_name'] as String? ?? '',
      questionDescription: json['question_description'] as String?,
      questionType: json['question_type'] as String? ?? 'single',
      languageId: _toInt(json['language_id']) ?? 1,
      options: options
          .map(
            (item) => FeedbackOptionModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class FeedbackFormFieldModel extends FeedbackFormField {
  const FeedbackFormFieldModel({
    required super.field,
    required super.question,
    required super.type,
    super.options,
  });

  factory FeedbackFormFieldModel.fromJson(Map<String, dynamic> json) {
    final options = json['options'] as List<dynamic>? ?? [];

    return FeedbackFormFieldModel(
      field: json['field'] as String? ?? '',
      question: json['question'] as String? ?? '',
      type: json['type'] as String? ?? 'single',
      options: options.map((e) => e.toString()).toList(),
    );
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
