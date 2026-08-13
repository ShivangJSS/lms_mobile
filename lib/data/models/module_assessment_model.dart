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

List<Map<String, dynamic>> _list(dynamic v) =>
    (v as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

class AssessmentQuestionItemModel extends AssessmentQuestionItem {
  const AssessmentQuestionItemModel({
    required super.type,
    required super.questionId,
    required super.questionTitle,
    super.questionDescription,
    super.imageUrl,
    super.marks,
    super.allowsMultiple,
    super.options,
    super.buckets,
    super.items,
    super.leftItems,
    super.rightItems,
  });

  factory AssessmentQuestionItemModel.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestionItemModel(
      type: json['type'] as String? ?? 'MCQ',
      questionId: _toInt(json['question_id']) ?? 0,
      questionTitle: json['question_title'] as String? ?? '',
      questionDescription: json['question_description'] as String?,
      imageUrl: json['image_url'] as String?,
      marks: _toDouble(json['marks']),
      allowsMultiple: json['allows_multiple'] == true,
      options: _list(json['options'])
          .map(
            (o) => ChoiceOption(
              optionId: _toInt(o['option_id']) ?? 0,
              optionText: o['option_text'] as String? ?? '',
            ),
          )
          .toList(),
      buckets: _list(json['buckets'])
          .map(
            (b) => Bucket(
              bucketId: _toInt(b['bucket_id']) ?? 0,
              name: b['bucket_name'] as String? ?? '',
              image: b['bucket_image'] as String?,
            ),
          )
          .toList(),
      items: _list(json['items'])
          .map(
            (i) => DraggableItem(
              itemId: _toInt(i['item_id']) ?? 0,
              name: i['item_name'] as String? ?? '',
              image: i['item_image'] as String?,
            ),
          )
          .toList(),
      leftItems: _list(json['left_items'])
          .map(
            (l) => MatchItem(
              itemId: _toInt(l['item_id']) ?? 0,
              text: l['text'] as String? ?? '',
            ),
          )
          .toList(),
      rightItems: _list(json['right_items'])
          .map(
            (r) => MatchItem(
              itemId: _toInt(r['item_id']) ?? 0,
              text: r['text'] as String? ?? '',
            ),
          )
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
    return ModuleAssessmentModel(
      moduleId: _toInt(json['module_id']) ?? 0,
      passPercentage: _toDouble(json['pass_percentage']),
      questions: _list(json['questions'])
          .map(AssessmentQuestionItemModel.fromJson)
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
    super.wrongAnswers,
    super.partiallyCorrect,
    super.nextModuleId,
    super.nextModuleName,
  });

  factory AssessmentResultModel.fromJson(Map<String, dynamic> json) {
    final total = _toInt(json['total_questions']) ?? 0;
    final correct = _toInt(json['correct_answers']) ?? 0;

    return AssessmentResultModel(
      totalQuestions: total,
      correctAnswers: correct,
      wrongAnswers: _toInt(json['wrong_answers']) ?? (total - correct),
      partiallyCorrect: _toInt(json['partially_correct']) ?? 0,
      scorePercentage: _toDouble(json['score_percentage']),
      passPercentage: _toDouble(json['pass_percentage']),
      passed: json['passed'] == true,
      moduleCompleted: json['module_completed'] == true,
      nextModuleId: _toInt(json['next_module_id']),
      nextModuleName: json['next_module_name'] as String?,
    );
  }
}
