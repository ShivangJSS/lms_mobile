import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/routes/app_routes.dart';
import 'core/services/language_storage.dart';
import 'core/theme/app_theme.dart';
import 'presentation/viewmodels/language_view_model.dart';
import 'presentation/viewmodels/login_view_model.dart';

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

  // The animated splash screen has been removed; instead we restore any saved
  // session here and open straight on the right screen.
  bool hasSession = false;
  try {
    hasSession =
        await container.read(loginViewModelProvider.notifier).restoreSession();
  } catch (_) {
    hasSession = false;
  }

  final router = AppRoutes.buildRouter(
    initialLocation: hasSession ? AppRoutes.home : AppRoutes.login,
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
