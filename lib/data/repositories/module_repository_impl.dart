import '../../domain/entities/learning_module.dart';
import '../../domain/repositories/module_repository.dart';
import '../datasource/remote/module_remote_datasource.dart';

class ModuleRepositoryImpl implements ModuleRepository {
  final ModuleRemoteDataSource dataSource;

  ModuleRepositoryImpl(this.dataSource);

  @override
  Future<List<LearningModule>> getModules({
    required int languageId,
    int? moduleType,
  }) async {
    return await dataSource.getModules(
      languageId: languageId,
      moduleType: moduleType,
    );
  }

  @override
  Future<List<ModuleCategory>> getModuleTypes() async {
    return await dataSource.getModuleTypes();
  }

  @override
  Future<List<AppLanguage>> getLanguages() async {
    return await dataSource.getLanguages();
  }

  @override
  Future<ModuleContent> getModuleTopics({
    required int moduleId,
    required int languageId,
  }) async {
    return await dataSource.getModuleTopics(
      moduleId: moduleId,
      languageId: languageId,
    );
  }
}
