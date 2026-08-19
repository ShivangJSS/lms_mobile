import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/assessment/assessment_screen.dart';
import '../../presentation/screens/password/forgot_password_screen.dart';
import '../../presentation/screens/password/reset_password_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/feedback/feedback_screen.dart';
import '../../presentation/screens/module/module_assessment_screen.dart';
import '../../presentation/screens/module/module_detail_screen.dart';
import '../../presentation/screens/module/module_list_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String assessment = '/assessment';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String feedback = '/feedback';

  /// The two mood questions asked straight after sign-in.
  static const String moodCheck = '/mood-check';

  static const String modules = '/modules';

  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static String moduleDetailPath(int moduleId) => '/modules/$moduleId';

  static String moduleAssessmentPath(int moduleId) =>
      '/modules/$moduleId/assessment';

  static int _moduleIdOf(GoRouterState state) =>
      int.tryParse(state.pathParameters['moduleId'] ?? '') ?? 0;

  /// Builds the app router. [initialLocation] is decided at startup from the
  /// saved session (home when signed in, login otherwise) — there is no longer
  /// a splash screen in between.
  static GoRouter buildRouter({String initialLocation = login}) => GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: assessment,
        builder: (context, state) => const AssessmentScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: moodCheck,
        builder: (context, state) => const FeedbackScreen(
          mode: FeedbackMode.mood,
        ),
      ),
      GoRoute(
        path: feedback,
        builder: (context, state) => const FeedbackScreen(
          mode: FeedbackMode.full,
        ),
      ),
      GoRoute(
        path: modules,
        builder: (context, state) => const ModuleListScreen(),
        routes: [
          GoRoute(
            path: ':moduleId',
            builder: (context, state) => ModuleDetailScreen(
              moduleId: _moduleIdOf(state),
              // Passed through so the header reads correctly before the
              // topics have loaded.
              moduleName: state.extra as String? ?? '',
            ),
            routes: [
              GoRoute(
                path: 'assessment',
                builder: (context, state) => ModuleAssessmentScreen(
                  moduleId: _moduleIdOf(state),
                  moduleName: state.extra as String? ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
