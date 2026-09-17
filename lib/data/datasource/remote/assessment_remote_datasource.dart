import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../domain/entities/assessment_answer.dart';
import '../../models/module_assessment_model.dart';

class ModuleAssessmentRemoteDataSource {
  final Dio _dio = ApiClient.dio;

  /// GET /mobile/module/assessment/{module_id}
  // Future<ModuleAssessmentModel> getAssessment({
  //   required int moduleId,
  //   required int languageId,
  // }) async {
  //
  //
  //   print("========== ASSESSMENT REQUEST ==========");
  //   print("MODULE ID = $moduleId");
  //   print("LANGUAGE ID = $languageId");
  //
  //   final response = await _dio.get(
  //     ApiConstants.moduleAssessment(moduleId),
  //     queryParameters: {'language_id': languageId},
  //   );
  //
  // Future<ModuleAssessmentModel> getAssessment({
  //   required int moduleId,
  //   required int languageId,
  // }) async {
  //   final response = await _dio.get(
  //     ApiConstants.moduleAssessment(moduleId),
  //     queryParameters: {
  //       'language_id': languageId,
  //       '_t': DateTime.now().millisecondsSinceEpoch, // <--- Add this timestamp
  //     },
  //     options: Options(
  //       headers: {
  //         'Cache-Control': 'no-cache, no-store, must-revalidate',
  //         'Pragma': 'no-cache',
  //       },
  //     ),
  //   );
  //   return ModuleAssessmentModel.fromJson(
  //     response.data as Map<String, dynamic>,
  //   );
  // }

  /// GET /mobile/module/assessment/{module_id}
  Future<ModuleAssessmentModel> getAssessment({
    required int moduleId,
    required int languageId,
  }) async {
    final response = await _dio.get(
      ApiConstants.moduleAssessment(moduleId),
      queryParameters: {
        'language_id': languageId,
        // This timestamp ensures you see Web Admin changes immediately
        // without ever having to "Clear Cache" again.
        '_t': DateTime.now().millisecondsSinceEpoch,
      },
    );

    return ModuleAssessmentModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// POST /mobile/module/assessment/{module_id}/submit
  Future<AssessmentResultModel> submit({
    required int moduleId,
    required int languageId,
    required List<AssessmentAnswer> answers,
  }) async {
    final response = await _dio.post(
      ApiConstants.moduleAssessmentSubmit(moduleId),
      queryParameters: {'language_id': languageId},
      data: {
        'answers': answers.map((answer) => answer.toJson()).toList(),
      },
    );

    return AssessmentResultModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
