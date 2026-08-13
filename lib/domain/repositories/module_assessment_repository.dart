import '../entities/module_assessment.dart';

abstract class ModuleAssessmentRepository {
  Future<ModuleAssessment> getAssessment({
    required int moduleId,
    required int languageId,
  });

  Future<AssessmentResult> submit({
    required int moduleId,
    required Map<int, List<int>> answers,
  });
}
