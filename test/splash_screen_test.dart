import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:women_with_wheels_refactor/core/routes/app_routes.dart';
import 'package:women_with_wheels_refactor/presentation/screens/splash/splash_screen.dart';

/// The launch screen has failed twice in ways these tests would have caught:
/// once painting nothing at all, and once holding the app on a blank window
/// while an unreachable backend timed out. It has to appear, and it has to let
/// go.
void main() {
  Widget harness() {
    return ProviderScope(
      child: MaterialApp.router(routerConfig: AppRoutes.buildRouter()),
    );
  }

  /// Secure storage has no platform channel under test, so the session check
  /// never answers and runs out its five second budget — the same path a
  /// launch with an unreachable backend takes. Waiting it out leaves no timer
  /// pending at teardown.
  Future<void> settleThrough(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  }

  Finder splashImage() => find.descendant(
        of: find.byType(SplashScreen),
        matching: find.byType(Image),
      );

  testWidgets('the app opens on the splash artwork', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);

    // The artwork itself, not an empty coloured window.
    final image = tester.widget<Image>(splashImage());

    expect(
      (image.image as AssetImage).assetName,
      'assets/images/azad_splash.jpg',
    );
    expect(image.fit, BoxFit.cover);

    await settleThrough(tester);
  });

  testWidgets('the artwork fills the screen', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 746);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(splashImage()), const Size(360, 746));

    await settleThrough(tester);
  });

  testWidgets('it hands off to the login page rather than sitting there',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(393, 873);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pump();

    await settleThrough(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.text('Welcome Back!'), findsOneWidget);
  });

  testWidgets('it does not leave before the artwork has been seen',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();

    // Well past any quick session answer, but inside the minimum show.
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(SplashScreen), findsOneWidget);

    await settleThrough(tester);
  });
}
