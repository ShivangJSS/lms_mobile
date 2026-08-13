import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/module_assessment_model.dart';

class ModuleAssessmentRemoteDataSource {
  final Dio _dio = ApiClient.dio;

  /// GET /mobile/module/assessment/{module_id}
  Future<ModuleAssessmentModel> getAssessment({
    required int moduleId,
    required int languageId,
  }) async {
    final response = await _dio.get(
      ApiConstants.moduleAssessment(moduleId),
      queryParameters: {'language_id': languageId},
    );

    return ModuleAssessmentModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// POST /mobile/module/assessment/{module_id}/submit
  Future<AssessmentResultModel> submit({
    required int moduleId,
    required Map<int, List<int>> answers,
  }) async {
    final response = await _dio.post(
      ApiConstants.moduleAssessmentSubmit(moduleId),
      data: {
        'answers': answers.entries
            .map(
              (entry) => {
                'mcq_id': entry.key,
                'selected_options': entry.value,
              },
            )
            .toList(),
      },
    );

    return AssessmentResultModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
