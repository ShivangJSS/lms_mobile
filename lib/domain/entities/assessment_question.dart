import 'package:equatable/equatable.dart';

/// Question shown by the assessment screen.
///
/// Kept separate from [FeedbackQuestion] because the feedback screen now
/// talks to the real API and needs option ids, while the assessment screen
/// still runs on placeholder data until an assessment API exists.
class AssessmentQuestion extends Equatable {
  final String id;
  final String questionText;
  final String questionType;
  final List<String> options;

  const AssessmentQuestion({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.options,
  });

  @override
  List<Object?> get props => [
        id,
        questionText,
        questionType,
        options,
      ];
}
