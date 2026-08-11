import 'package:dio/dio.dart';

import ' auth_interceptor.dart';
import 'api_constants.dart';


class ApiClient {
  ApiClient._();

  static Dio? _dio;

  static Dio get dio {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    _dio!.interceptors.add(
      AuthInterceptor(_dio!),
    );

    return _dio!;
  }
}