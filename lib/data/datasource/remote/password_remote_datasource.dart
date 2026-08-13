import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';

class PasswordRemoteDataSource {
  final Dio _dio = ApiClient.dio;

  /// POST /mobile/auth/forgot-password -> short-lived reset token.
  Future<String> requestReset(String username) async {
    final response = await _dio.post(
      ApiConstants.forgotPassword,
      data: {'username': username},
    );

    return response.data['reset_token'] as String;
  }

  /// POST /mobile/auth/reset-password
  Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _dio.post(
      ApiConstants.resetPassword,
      data: {
        'reset_token': resetToken,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );

    return response.data['message'] as String? ?? 'Password reset.';
  }
}
