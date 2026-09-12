import 'package:equatable/equatable.dart';

/// One option of a post-video question.
class VideoQuizOption extends Equatable {
  final int optionId;
  final String? optionText;
  final bool isCorrect;

  const VideoQuizOption({
    required this.optionId,
    this.optionText,
    this.isCorrect = false,
  });

  factory VideoQuizOption.fromJson(Map<String, dynamic> json) {
    return VideoQuizOption(
      optionId: (json['option_id'] as num?)?.toInt() ?? 0,
      optionText: json['option_text'] as String?,
      isCorrect: json['is_correct'] == true,
    );
  }

  @override
  List<Object?> get props => [optionId, optionText, isCorrect];
}

/// A question shown after a video. Both MCQ and SCQ arrive in this shape; the
/// only difference the UI cares about is single- vs multi-select.
class VideoQuizQuestion extends Equatable {
  /// "MCQ" or "SCQ".
  final String type;
  final int questionId;
  final String? questionTitle;
  final String? questionDescription;
  final double marks;
  final List<VideoQuizOption> options;

  const VideoQuizQuestion({
    required this.type,
    required this.questionId,
    this.questionTitle,
    this.questionDescription,
    this.marks = 1.0,
    this.options = const [],
  });

  bool get allowsMultiple => type.toUpperCase() == 'MCQ';

  factory VideoQuizQuestion.fromJson(Map<String, dynamic> json) {
    return VideoQuizQuestion(
      type: (json['type'] as String?) ?? 'SCQ',
      questionId: (json['question_id'] as num?)?.toInt() ?? 0,
      questionTitle: json['question_title'] as String?,
      questionDescription: json['question_description'] as String?,
      marks: (json['marks'] as num?)?.toDouble() ?? 1.0,
      options: ((json['options'] as List<dynamic>?) ?? [])
          .map((e) => VideoQuizOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props =>
      [type, questionId, questionTitle, questionDescription, marks, options];
}
