class ApiConstants {
  ApiConstants._();

  // Physical Device on same Wi-Fi as the laptop running the FastAPI backend.
  // Laptop LAN IP (en0) + backend port (uvicorn on 0.0.0.0:8090).
  static const String baseUrl = 'http://10.243.237.169:8090';

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
