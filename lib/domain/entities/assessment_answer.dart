import 'package:equatable/equatable.dart';

import 'module_assessment.dart';

/// What the participant has entered for one question, whatever its type.
class AssessmentAnswer extends Equatable {
  final String type;
  final int questionId;

  /// MCQ / SCQ
  final List<int> selectedOptions;

  /// Drop bucket: item_id -> bucket_id
  final Map<int, int> placements;

  /// Match making: left_id -> right_id
  final Map<int, int> pairs;

  const AssessmentAnswer({
    required this.type,
    required this.questionId,
    this.selectedOptions = const [],
    this.placements = const {},
    this.pairs = const {},
  });

  bool get isAnswered {
    if (type == QuestionType.dropBucket) return placements.isNotEmpty;
    if (type == QuestionType.matchMaking) return pairs.isNotEmpty;
    return selectedOptions.isNotEmpty;
  }

  AssessmentAnswer copyWith({
    List<int>? selectedOptions,
    Map<int, int>? placements,
    Map<int, int>? pairs,
  }) {
    return AssessmentAnswer(
      type: type,
      questionId: questionId,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      placements: placements ?? this.placements,
      pairs: pairs ?? this.pairs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'question_id': questionId,
      'selected_options': selectedOptions,
      'placements': placements.entries
          .map((e) => {'item_id': e.key, 'bucket_id': e.value})
          .toList(),
      'pairs': pairs.entries
          .map((e) => {'left_id': e.key, 'right_id': e.value})
          .toList(),
    };
  }

  @override
  List<Object?> get props => [
        type,
        questionId,
        selectedOptions,
        placements,
        pairs,
      ];
}
