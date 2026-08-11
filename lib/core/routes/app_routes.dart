import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/assessment/assessment_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/feedback/feedback_screen.dart';
import '../../presentation/screens/module/module_list_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String assessment = '/assessment';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String feedback = '/feedback';
  static const String modules = '/modules';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
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
        path: feedback,
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: modules,
        builder: (context, state) => const ModuleListScreen(),
      ),
    ],
  );
}
