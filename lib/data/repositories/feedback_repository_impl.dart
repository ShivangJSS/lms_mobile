import '../../domain/entities/feedback_question.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../datasource/local/dummy_feedback_data_source.dart';

class AssessmentRepositoryImpl implements AssessmentRepository {
  final DummyFeedbackDataSource dataSource;

  AssessmentRepositoryImpl(this.dataSource);

  @override
  Future<List<FeedbackQuestion>> getFeedbackQuestions() async {
    return await dataSource.getFeedbackQuestions();
  }

  @override
  Future<bool> submitFeedback(Map<String, dynamic> answers) async {
    return await dataSource.submitFeedback(answers);
  }
}