import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/dashboard_stats_model.dart';
import '../../models/dashboard_tip_model.dart';

class DashboardRemoteDataSource {
  final Dio _dio = ApiClient.dio;

  /// The participant is resolved from the bearer token by the backend,
  /// so no id has to be sent.
  Future<DashboardStatsModel> getDashboardStats() async {
    final response = await _dio.get(
      ApiConstants.dashboardStats,
    );

    return DashboardStatsModel.fromJson(response.data);
  }

  /// GET /mobile/dashboard/tips
  Future<List<DashboardTipModel>> getTips({required int languageId}) async {
    final response = await _dio.get(
      ApiConstants.dashboardTips,
      queryParameters: {'language_id': languageId},
    );

    final tips = response.data as List<dynamic>? ?? [];

    return tips
        .map(
          (item) => DashboardTipModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
