import '../entities/learning_module.dart';

abstract class ModuleRepository {
  Future<List<LearningModule>> getModules({
    required int languageId,
    int? moduleType,
  });

  Future<List<ModuleCategory>> getModuleTypes();

  Future<List<AppLanguage>> getLanguages();

  Future<ModuleContent> getModuleTopics({
    required int moduleId,
    required int languageId,
  });
}
