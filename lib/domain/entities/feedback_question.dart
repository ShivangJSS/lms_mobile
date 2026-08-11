import 'package:equatable/equatable.dart';

class FeedbackQuestion extends Equatable {
  final String id;
  final String questionText;
  final String questionType;
  final List<String> options;

  const FeedbackQuestion({
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