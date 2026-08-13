import 'package:equatable/equatable.dart';

class FeedbackOption extends Equatable {
  final int optionId;
  final String optionName;
  final String? optionIcon;

  const FeedbackOption({
    required this.optionId,
    required this.optionName,
    this.optionIcon,
  });

  @override
  List<Object?> get props => [optionId, optionName, optionIcon];
}

/// Mood question from GET /mobile/feedback/questions.
class FeedbackQuestion extends Equatable {
  final int questionId;
  final String questionName;
  final String? questionDescription;

  /// The API stores this free-form; values seen are "single" and "Multiple".
  final String questionType;

  final int languageId;
  final List<FeedbackOption> options;

  const FeedbackQuestion({
    required this.questionId,
    required this.questionName,
    required this.questionType,
    required this.languageId,
    this.questionDescription,
    this.options = const [],
  });

  bool get allowsMultiple =>
      questionType.trim().toLowerCase().startsWith('multi');

  @override
  List<Object?> get props => [
        questionId,
        questionName,
        questionDescription,
        questionType,
        languageId,
        options,
      ];
}

/// One question of the full trainee questionnaire, from
/// GET /mobile/feedback/form. Answers are written to the matching
/// participant_feedback column named by [field].
class FeedbackFormField extends Equatable {
  final String field;
  final String question;

  /// "single", "multiple" or "text".
  final String type;

  final List<String> options;

  const FeedbackFormField({
    required this.field,
    required this.question,
    required this.type,
    this.options = const [],
  });

  bool get isText => type == 'text';

  bool get isMultiple => type == 'multiple';

  @override
  List<Object?> get props => [field, question, type, options];
}
