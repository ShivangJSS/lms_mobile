import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/routes/app_routes.dart';
import 'core/services/language_storage.dart';
import 'core/theme/app_theme.dart';
import 'presentation/viewmodels/language_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Nothing before runApp() may throw. An uncaught error in main() takes the
  // root isolate down with it, which surfaces as "Lost connection to device"
  // and leaves the debugger nothing to attach to — the app dies before it ever
  // paints. Reading preferences can fail on its own (a plugin channel that is
  // not up yet, a wiped profile), so it falls back to the default language
  // rather than bringing the process down.
  var languageId = LanguageStorage.defaultLanguageId;

  try {
    languageId = await LanguageStorage.get();
  } catch (_) {
    // Keeps the default.
  }

  // Decoded before the first frame on purpose. Until a 1.4 MB, 853x1844 PNG
  // finishes decoding the Image widget paints nothing at all, so the splash
  // screen would come up as a bare background and the illustration would pop in
  // afterwards — which is two screens, not one. The Android launch window is
  // showing the same artwork while this happens.
  await _precacheSplashArtwork();

  // A shared container so the session the splash screen restores survives
  // into the app.
  final container = ProviderContainer(
    overrides: [
      initialLanguageIdProvider.overrideWithValue(languageId),
    ],
  );

  // Nothing else is awaited here. Restoring the session is a network round
  // trip, and doing it before runApp held the first frame for as long as it
  // took — an unreachable backend left the launch window blank for Dio's full
  // timeout. SplashScreen now does that check with the artwork already on
  // screen, and picks the same destination it always did.
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

/// Decodes the splash artwork into the image cache before `runApp`.
///
/// Resolved against [ImageConfiguration.empty] rather than through
/// `precacheImage`, which needs a BuildContext that does not exist yet.
Future<void> _precacheSplashArtwork() async {
  const provider = AssetImage('assets/images/azad_splash.jpg');

  final completer = Completer<void>();
  final stream = provider.resolve(ImageConfiguration.empty);

  late final ImageStreamListener listener;

  void finish() {
    stream.removeListener(listener);

    if (!completer.isCompleted) completer.complete();
  }

  listener = ImageStreamListener(
    (_, __) => finish(),
    onError: (_, __) => finish(),
  );

  stream.addListener(listener);

  // A missing or corrupt asset must not hold the launch.
  await completer.future.timeout(
    const Duration(seconds: 3),
    onTimeout: () {},
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
