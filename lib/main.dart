import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: WomenWithWheelsApp(),
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
