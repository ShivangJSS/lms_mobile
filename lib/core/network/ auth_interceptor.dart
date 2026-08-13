import 'package:dio/dio.dart';

import '../services/token_storage.dart';
import 'api_constants.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  /// Marks a request that has already been retried once, so a persistently
  /// rejected token cannot cause an endless refresh loop.
  static const _retriedKey = "__retried_after_refresh";

  AuthInterceptor(this.dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
    }

    options.headers["Accept"] = "application/json";
    options.headers["Content-Type"] = "application/json";

    return handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;

    final shouldRefresh = err.response?.statusCode == 401 &&
        request.extra[_retriedKey] != true &&
        !request.path.contains(ApiConstants.refresh) &&
        !request.path.contains(ApiConstants.login);

    if (!shouldRefresh) {
      return handler.next(err);
    }

    final refreshed = await _refreshTokens();

    if (!refreshed) {
      await TokenStorage.clear();
      return handler.next(err);
    }

    try {
      request.extra[_retriedKey] = true;

      final response = await dio.fetch(request);

      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Uses a bare Dio so this call does not run back through this interceptor.
  Future<bool> _refreshTokens() async {
    final refreshToken = await TokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await Dio(
        BaseOptions(baseUrl: ApiConstants.baseUrl),
      ).post(
        ApiConstants.refresh,
        data: {"refresh_token": refreshToken},
      );

      final data = response.data as Map<String, dynamic>;

      await TokenStorage.saveTokens(
        accessToken: data["access_token"] as String,
        refreshToken: data["refresh_token"] as String,
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}
