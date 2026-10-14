import '../entities/assessment_answer.dart';
import '../entities/module_assessment.dart';

abstract class ModuleAssessmentRepository {
  Future<ModuleAssessment> getAssessment({
    required int moduleId,
    required int languageId,
    String type = 'post', // <--- Add this
  });

  Future<AssessmentResult> submit({
    required int moduleId,
    required int languageId,
    required List<AssessmentAnswer> answers,
    String type = 'post', // <--- Add this
  });
}
