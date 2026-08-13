// Routing configuration test.
//
// This replaces the counter test left over from `flutter create`, which
// referenced a `MyApp` class that never existed in this project and so failed
// on every run.
//
// Pumping the whole app is not useful here: the splash screen starts a timer
// and reads secure storage, neither of which exist under test. Checking the
// route table catches the thing that actually breaks — a screen losing its
// route — without any of that.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:women_with_wheels_refactor/core/routes/app_routes.dart';

void main() {
  Set<String> collect(List<RouteBase> routes, [String prefix = '']) {
    final paths = <String>{};

    for (final route in routes) {
      if (route is GoRoute) {
        final full = route.path.startsWith('/')
            ? route.path
            : '$prefix/${route.path}';

        paths.add(full);
        paths.addAll(collect(route.routes, full));
      }
    }

    return paths;
  }

  test('every screen is reachable by route', () {
    final paths = collect(AppRoutes.router.configuration.routes);

    for (final expected in [
      '/',
      AppRoutes.login,
      AppRoutes.forgotPassword,
      AppRoutes.resetPassword,
      AppRoutes.home,
      AppRoutes.profile,
      AppRoutes.feedback,
      AppRoutes.moodCheck,
      AppRoutes.modules,
    ]) {
      expect(paths, contains(expected), reason: '$expected is not routed');
    }
  });

  test('module detail and its assessment are nested under modules', () {
    final paths = collect(AppRoutes.router.configuration.routes);

    expect(paths, contains('/modules/:moduleId'));
    expect(paths, contains('/modules/:moduleId/assessment'));
  });

  test('path builders produce the nested routes', () {
    expect(AppRoutes.moduleDetailPath(9), '/modules/9');
    expect(AppRoutes.moduleAssessmentPath(9), '/modules/9/assessment');
  });

  test('the mood check is a separate route from full feedback', () {
    // Straight after sign-in only the two mood questions are asked; the
    // longer questionnaire lives behind Feedback in the side navigation.
    expect(AppRoutes.moodCheck, isNot(AppRoutes.feedback));
  });
}
