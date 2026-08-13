import '../../domain/entities/assessment_question.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../datasource/local/dummy_assessment_data_source.dart';

/// Backed by placeholder data — see [DummyAssessmentDataSource].
class AssessmentRepositoryImpl implements AssessmentRepository {
  final DummyAssessmentDataSource dataSource;

  AssessmentRepositoryImpl(this.dataSource);

  @override
  Future<List<AssessmentQuestion>> getAssessmentQuestions() async {
    return await dataSource.getAssessmentQuestions();
  }

  @override
  Future<bool> submitAssessment(Map<String, String> answers) async {
    return await dataSource.submitAssessment(answers);
  }
}
