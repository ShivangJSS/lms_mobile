import '../../domain/entities/assessment_answer.dart';
import '../../domain/entities/module_assessment.dart';
import '../../domain/repositories/module_assessment_repository.dart';
import '../datasource/remote/assessment_remote_datasource.dart';

class ModuleAssessmentRepositoryImpl implements ModuleAssessmentRepository {
  final ModuleAssessmentRemoteDataSource dataSource;

  ModuleAssessmentRepositoryImpl(this.dataSource);

  @override
  Future<ModuleAssessment> getAssessment({
    required int moduleId,
    required int languageId,
  }) async {
    return await dataSource.getAssessment(
      moduleId: moduleId,
      languageId: languageId,
    );
  }

  @override
  Future<AssessmentResult> submit({
    required int moduleId,
    required int languageId,
    required List<AssessmentAnswer> answers,
  }) async {
    return await dataSource.submit(
      moduleId: moduleId,
      languageId: languageId,
      answers: answers,
    );
  }
}
