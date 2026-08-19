import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/routes/app_routes.dart';
import 'core/services/language_storage.dart';
import 'core/theme/app_theme.dart';
import 'presentation/viewmodels/language_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read the saved language up front so every view model starts with it.
  final languageId = await LanguageStorage.get();

  // A shared container so the session restored below survives into the app.
  final container = ProviderContainer(
    overrides: [
      initialLanguageIdProvider.overrideWithValue(languageId),
    ],
  );

  // Open straight on the splash screen so Flutter draws immediately (the OS
  // launch screen is dismissed at once). The splash itself restores any saved
  // session during its two seconds, then routes to home or login.
  final router = AppRoutes.buildRouter(
    initialLocation: AppRoutes.splash,
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: WomenWithWheelsApp(router: router),
    ),
  );
}

class WomenWithWheelsApp extends StatelessWidget {
  final GoRouter router;

  const WomenWithWheelsApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Women with Wheels',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Using light theme by default as per screenshots
      routerConfig: router,
    );
  }
}
