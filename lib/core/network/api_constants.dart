class ApiConstants {
  ApiConstants._();

  // Emulator
  static const String baseUrl = 'http://10.147.155.61:8000';

  // Physical Device
  // static const String baseUrl = "http://192.168.1.10:8000";

  // Authentication APIs
  static const String login = "/mobile/auth/login";
  static const String refresh = "/mobile/auth/refresh";
  static const String logout = "/mobile/auth/logout";
  static const String me = "/mobile/auth/me";
}