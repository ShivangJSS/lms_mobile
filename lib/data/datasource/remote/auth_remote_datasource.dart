import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../models/login_request.dart';
import '../../models/login_response.dart';
import '../../models/participant_model.dart';

class AuthRemoteDataSource {
  final Dio _dio = ApiClient.dio;

  Future<LoginResponse> login(LoginRequest request) async {
    print("========== LOGIN REQUEST ==========");
    print("URL: ${ApiConstants.baseUrl}${ApiConstants.login}");
    print("BODY: ${request.toJson()}");

    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );

    print("========== LOGIN RESPONSE ==========");
    print("STATUS: ${response.statusCode}");
    print("DATA: ${response.data}");

    return LoginResponse.fromJson(response.data);
  }

  Future<LoginResponse> refreshToken(
      String refreshToken,
      ) async {
    final response = await _dio.post(
      ApiConstants.refresh,
      data: {
        "refresh_token": refreshToken,
      },
    );

    return LoginResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    await _dio.post(
      ApiConstants.logout,
    );
  }

  Future<ParticipantModel> getCurrentUser() async {
    final response = await _dio.get(
      ApiConstants.me,
    );

    return ParticipantModel.fromJson(response.data);
  }
}