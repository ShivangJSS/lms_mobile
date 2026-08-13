import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/learning_module_model.dart';

class ModuleRemoteDataSource {
  final Dio _dio = ApiClient.dio;

  /// GET /mobile/module/list
  ///
  /// The participant comes from the bearer token. [moduleType] is the
  /// module_type_id to filter by, or null for every type.
  Future<List<LearningModuleModel>> getModules({
    required int languageId,
    int? moduleType,
  }) async {
    final response = await _dio.get(
      ApiConstants.moduleList,
      queryParameters: {
        'language_id': languageId,
        if (moduleType != null) 'module_type': moduleType,
      },
    );

    final modules = response.data['modules'] as List<dynamic>? ?? [];

    return modules
        .map(
          (item) => LearningModuleModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// GET /mobile/module/types
  Future<List<ModuleCategoryModel>> getModuleTypes() async {
    final response = await _dio.get(
      ApiConstants.moduleTypes,
    );

    final types = response.data as List<dynamic>? ?? [];

    return types
        .map(
          (item) => ModuleCategoryModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// GET /mobile/module/languages
  Future<List<AppLanguageModel>> getLanguages() async {
    final response = await _dio.get(
      ApiConstants.languages,
    );

    final languages = response.data as List<dynamic>? ?? [];

    return languages
        .map(
          (item) => AppLanguageModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// GET /mobile/module/{module_id}/topics
  Future<List<ModuleTopicModel>> getModuleTopics({
    required int moduleId,
    required int languageId,
  }) async {
    final response = await _dio.get(
      ApiConstants.moduleTopics(moduleId),
      queryParameters: {'language_id': languageId},
    );

    final topics = response.data['topics'] as List<dynamic>? ?? [];

    return topics
        .map(
          (item) => ModuleTopicModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
