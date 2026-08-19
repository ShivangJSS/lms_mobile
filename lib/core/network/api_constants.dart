class ApiConstants {
  ApiConstants._();

  // Physical device on the same Wi-Fi as the laptop running the FastAPI
  // backend: the laptop's LAN address plus the uvicorn port.

  // This has to be re-checked whenever the laptop changes network — the
  // address is handed out by DHCP and does not follow the machine. Confirm the
  // laptop's current one (`ipconfig` on Windows, `ifconfig` on macOS) and that
  // uvicorn is bound to 0.0.0.0 rather than 127.0.0.1, or the phone cannot see
  // it. When it is wrong every call sits out Dio's 30 second connect timeout
  // instead of failing fast.


  static const String baseUrl = 'http://10.250.153.122:8000';

  // Previous values:
  // static const String baseUrl = 'http://10.147.155.61:8000';
  // static const String baseUrl = "http://192.168.1.10:8000";

  // Authentication APIs
  static const String login = "/mobile/auth/login";
  static const String refresh = "/mobile/auth/refresh";
  static const String logout = "/mobile/auth/logout";
  static const String me = "/mobile/auth/me";

  /// Multipart upload of the participant's profile photo.
  static const String profilePhoto = "/mobile/module/profile/photo";

  // Password APIs
  static const String forgotPassword = "/mobile/auth/forgot-password";
  static const String resetPassword = "/mobile/auth/reset-password";
  static const String changePassword = "/mobile/auth/change-password";

  /// Streams stored videos, pdfs, ppts and images. Supports byte ranges, so
  /// video players can seek. Unauthenticated by design — image and video
  /// widgets cannot attach the bearer token.
  static const String media = "/mobile/module/media";

  // Dashboard APIs
  static const String dashboardStats = "/mobile/dashboard/stats";
  static const String dashboardTips = "/mobile/dashboard/tips";

  // Assessment APIs
  static String moduleAssessment(int moduleId) =>
      "/mobile/module/assessment/$moduleId";

  static String moduleAssessmentSubmit(int moduleId) =>
      "/mobile/module/assessment/$moduleId/submit";

  // Module APIs
  static const String moduleList = "/mobile/module/list";
  static const String moduleTypes = "/mobile/module/types";
  static const String languages = "/mobile/module/languages";

  static String moduleTopics(int moduleId) =>
      "/mobile/module/$moduleId/topics";

  // Feedback APIs
  static const String feedbackQuestions = "/mobile/feedback/questions";
  static const String feedbackForm = "/mobile/feedback/form";
  static const String feedbackSubmit = "/mobile/feedback/submit";
}
