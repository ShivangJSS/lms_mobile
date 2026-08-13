import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes/app_routes.dart';
import 'core/services/language_storage.dart';
import 'core/theme/app_theme.dart';
import 'presentation/viewmodels/language_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read the saved language up front so every view model starts with it.
  final languageId = await LanguageStorage.get();

  runApp(
    ProviderScope(
      overrides: [
        initialLanguageIdProvider.overrideWithValue(languageId),
      ],
      child: const WomenWithWheelsApp(),
    ),
  );
}

class WomenWithWheelsApp extends ConsumerWidget {
  const WomenWithWheelsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Women with Wheels',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Using light theme by default as per screenshots
      routerConfig: AppRoutes.router,
    );
  }
}
