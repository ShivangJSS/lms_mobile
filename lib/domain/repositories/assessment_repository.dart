import '../entities/assessment_question.dart';

abstract class AssessmentRepository {
  Future<List<AssessmentQuestion>> getAssessmentQuestions();

  Future<bool> submitAssessment(Map<String, String> answers);
}
