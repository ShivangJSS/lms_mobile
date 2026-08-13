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
    required Map<int, List<int>> answers,
  }) async {
    return await dataSource.submit(moduleId: moduleId, answers: answers);
  }
}
