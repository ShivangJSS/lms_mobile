import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:women_with_wheels_refactor/presentation/screens/login/login_screen.dart';

/// Guards the login screen's one hard rule: it is a single, unscrollable page
/// that must fit every phone we support without overflowing.
///
/// A Spacer inside a SingleChildScrollView has no bounded height to work
/// against; the layout threw and the whole page painted empty. These tests
/// pump the real screen at several sizes and fail on any layout exception.
void main() {
  Widget harness() => const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      );

  /// Sizes are LOGICAL pixels, which is what layout actually works in.
  ///
  /// An earlier version passed physical sizes like 1080x2400 with a device
  /// pixel ratio of 1, which is a tablet-sized canvas — it reported no
  /// overflow while a real 393x873 phone overflowed by 22px.
  Future<void> pumpAt(WidgetTester tester, Size logicalSize) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = logicalSize;

    // Without this the tests measure a phone that does not exist. A real
    // handset spends its top ~30pt on the status bar, which the header's
    // SafeArea has to pay for; leaving it at zero made every one of these
    // sizes ~30pt more generous than the device and let the carousel "fit"
    // in tests while vanishing on hardware.
    tester.view.padding = const FakeViewPadding(top: 30 * 1.0);

    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pump();
  }

  testWidgets('renders its content on a normal phone', (tester) async {
    await pumpAt(tester, const Size(393, 873));

    expect(tester.takeException(), isNull);

    // Header.
    expect(find.text('E-Learning Portal'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Grow'), findsOneWidget);
    expect(find.text('Empower'), findsOneWidget);

    // Sign-in card.
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(
      find.text('Sign in to continue your learning journey'),
      findsOneWidget,
    );
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Enter your username'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);

    // Carousel: the photo only, with no caption written over it.
    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('Women in Action'), findsNothing);
    expect(find.text('See All'), findsNothing);
    expect(find.text('Know More'), findsNothing);
    expect(find.textContaining('Green Signal'), findsNothing);

    // Both inputs are present and usable.
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('the card is sign-in only — no forgot, guest or OR',
      (tester) async {
    await pumpAt(tester, const Size(393, 873));

    expect(find.text('Forgot password?'), findsNothing);
    expect(find.text('OR'), findsNothing);
    expect(find.text('Continue as Guest'), findsNothing);
  });

  testWidgets('the tech-partner strip is gone', (tester) async {
    await pumpAt(tester, const Size(393, 873));

    expect(find.text('Tech Partner'), findsNothing);
    expect(find.text('Indev Consultancy Pvt Ltd'), findsNothing);
    expect(find.text('App Version 1.0.0'), findsNothing);
  });

  testWidgets('the header block is centred, not pinned to the left',
      (tester) async {
    // A Stack lays non-positioned children out loosely, so the header column
    // once shrink-wrapped and sat against the left edge.
    await pumpAt(tester, const Size(393, 873));

    const screenCentre = 393 / 2;

    final blocks = <String, Finder>{
      'logo': find.byType(Image),
      'title': find.text('E-Learning Portal'),
    };

    blocks.forEach((name, finder) {
      final rect = tester.getRect(finder.first);

      expect(
        rect.center.dx,
        closeTo(screenCentre, 1.5),
        reason: '$name is off-centre',
      );
    });

    // "Learn · Grow · Empower" is measured end to end: the middle word is not
    // the midpoint, because the outer two words are different widths.
    final tagline = tester.getRect(find.text('Learn')).left +
        tester.getRect(find.text('Empower')).right;

    expect(tagline / 2, closeTo(screenCentre, 1.5));
  });

  testWidgets('the logo is wide enough to read', (tester) async {
    await pumpAt(tester, const Size(393, 873));

    final logo = tester.getSize(find.byType(Image).first);

    // It is the brand mark, not a bullet: it should take up a good share of
    // the screen width.
    expect(logo.width, greaterThan(393 * 0.45));
  });

  // Real logical sizes: a compact phone, a common phone, and a large one.
  // 360x740 is the usable height of a 1080x2400 phone at 3x with a nav bar,
  // which is the device this was reported broken on.
  for (final size in const [
    Size(320, 568), // smallest still-supported phone
    Size(360, 640),
    Size(360, 746), // OPPO CPH2467, navigation bar subtracted
    Size(393, 873),
    Size(412, 915),
    Size(430, 932),
  ]) {
    testWidgets('fits ${size.width.toInt()}x${size.height.toInt()} '
        'without overflowing', (tester) async {
      await pumpAt(tester, size);

      // A RenderFlex overflow surfaces here, which is exactly what the
      // yellow-and-black stripe on the device was reporting.
      expect(tester.takeException(), isNull);
      expect(find.text('LOGIN'), findsOneWidget);
    });
  }

  testWidgets('the page itself is not scrollable', (tester) async {
    await pumpAt(tester, const Size(393, 873));

    // The page is pinned to the viewport with no scroll container to fall
    // back on, so any overflow would be a hard failure. The carousel's own
    // PageView is a Scrollable and is not what this checks.
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('drops the banner rather than overflowing when short',
      (tester) async {
    await pumpAt(tester, const Size(360, 640));

    expect(tester.takeException(), isNull);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
  });

  // The sizes a real phone actually reports. The test font is wider and taller
  // than the one on a device, so anything that fits here fits there too.
  for (final size in const [Size(360, 746), Size(393, 873), Size(412, 915)]) {
    testWidgets('keeps the banner at ${size.width.toInt()}x'
        '${size.height.toInt()}', (tester) async {
      await pumpAt(tester, size);

      expect(tester.takeException(), isNull);
      expect(find.byType(PageView), findsOneWidget);
      expect(
        tester.getSize(find.byType(PageView)).height,
        greaterThan(64),
        reason: 'the photo should not be a sliver',
      );
    });
  }

  testWidgets('the banner grows to fill the leftover space', (tester) async {
    Future<double> bannerHeight(Size size) async {
      await pumpAt(tester, size);

      return tester.getSize(find.byType(PageView)).height;
    }

    final onTall = await bannerHeight(const Size(430, 932));
    final onShorter = await bannerHeight(const Size(393, 873));

    // A taller screen never gets a SMALLER photo. Both of these sizes now sit
    // at the maxSlide cap, past which the extra height goes to the gaps rather
    // than to an ever-taller photo.
    expect(onTall, greaterThanOrEqualTo(onShorter));
    expect(onShorter, greaterThan(80));

    // Below the cap it does still grow with the screen, which is the part
    // that stops a dead gap opening above the footer.
    final small = await bannerHeight(const Size(360, 700));
    final larger = await bannerHeight(const Size(360, 790));

    expect(larger, greaterThan(small));
  });

  testWidgets('empty fields are rejected before any request', (tester) async {
    await pumpAt(tester, const Size(393, 873));

    await tester.tap(find.text('LOGIN'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Please enter username'), findsOneWidget);
    expect(find.text('Please enter password'), findsOneWidget);
  });

  testWidgets('showing both validation errors does not overflow',
      (tester) async {
    // The card grows by two lines of red text; on a page that cannot scroll
    // the space has to come from somewhere.
    for (final size in const [
      Size(320, 568),
      Size(360, 640),
      Size(360, 746),
      Size(393, 873),
    ]) {
      await pumpAt(tester, size);

      await tester.tap(find.text('LOGIN'));
      await tester.pump();

      expect(tester.takeException(), isNull, reason: '$size');
    }
  });

  testWidgets('password is obscured until the eye is tapped', (tester) async {
    await pumpAt(tester, const Size(393, 873));

    EditableText passwordField() => tester
        .widgetList<EditableText>(find.byType(EditableText))
        .last;

    expect(passwordField().obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(passwordField().obscureText, isFalse);
  });

  testWidgets('remember me starts ticked and toggles', (tester) async {
    await pumpAt(tester, const Size(393, 873));

    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.tap(find.text('Remember me'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.check), findsNothing);
  });
}
