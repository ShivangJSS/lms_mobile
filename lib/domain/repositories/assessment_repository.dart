import '../entities/feedback_question.dart';

abstract class AssessmentRepository {
  Future<List<FeedbackQuestion>> getFeedbackQuestions();
  Future<bool> submitFeedback(Map<String, String> answers);
}
