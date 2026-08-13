import '../entities/feedback_question.dart';

abstract class FeedbackRepository {
  Future<List<FeedbackQuestion>> getQuestions({
    required int languageId,
  });

  /// The full trainee questionnaire shown from the side navigation.
  Future<List<FeedbackFormField>> getForm();

  /// Returns the created feedback_id.
  Future<int> submit({
    String? lmsExperience,
    String? lmsEase,
    required List<String> usefulModules,
    required Map<int, List<int>> moodAnswers,
    Map<String, dynamic> formAnswers,
  });
}
