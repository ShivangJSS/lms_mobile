import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:women_with_wheels_refactor/presentation/screens/login/login_screen.dart';

/// Guards against the login screen rendering blank.
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

    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pump();
  }

  testWidgets('renders its content on a normal phone', (tester) async {
    await pumpAt(tester, const Size(393, 873));

    expect(tester.takeException(), isNull);

    expect(find.text('E-Learning @ WWW'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Women in Action'), findsOneWidget);

    // The sign-in card is hint-only now: no "Sign In" heading, no field
    // labels above the boxes, and no Forgot Password link.
    expect(find.text('Sign In'), findsNothing);
    expect(find.text('Username'), findsNothing);
    expect(find.text('Password'), findsNothing);
    expect(find.text('Forgot Password?'), findsNothing);
    expect(find.text('Enter your username'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    // The footer is a RichText, so spans have to be searched explicitly.
    expect(
      find.textContaining('Indev Consultancy', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('App version 1.0'), findsOneWidget);

    // Both inputs are present and usable.
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  // Real logical sizes: a compact phone, a common phone, and a large one.
  for (final size in const [
    Size(320, 568), // smallest still-supported phone
    Size(360, 640),
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

  testWidgets('spreads the space instead of pooling it at the bottom',
      (tester) async {
    await pumpAt(tester, const Size(393, 873));

    final header = tester.getRect(find.text('Learn · Grow · Lead'));
    final card = tester.getRect(find.byType(Form));
    final banner = tester.getRect(find.byType(PageView));
    final footer = tester.getRect(find.text('App version 1.0'));

    final headerToCard = card.top - header.bottom;
    final cardToBanner = banner.top - card.bottom;
    final bannerToFooter = footer.top - banner.bottom;

    // The heading block is no longer crammed against the card.
    expect(headerToCard, greaterThan(40));

    // And the gap under the banner is no longer the biggest thing on screen.
    expect(bannerToFooter, lessThan(headerToCard + cardToBanner));
  });

  testWidgets('drops the banner rather than overflowing when short',
      (tester) async {
    await pumpAt(tester, const Size(360, 640));

    expect(tester.takeException(), isNull);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Women in Action'), findsNothing);
  });

  testWidgets('keeps the banner when there is room', (tester) async {
    await pumpAt(tester, const Size(412, 915));

    expect(tester.takeException(), isNull);
    expect(find.text('Women in Action'), findsOneWidget);
  });

  testWidgets('the banner grows to fill the leftover space', (tester) async {
    Future<double> bannerHeight(Size size) async {
      await pumpAt(tester, size);

      return tester.getSize(find.byType(PageView)).height;
    }

    final onTall = await bannerHeight(const Size(430, 932));
    final onShorter = await bannerHeight(const Size(393, 873));

    // A taller screen gives the carousel more room rather than leaving a
    // dead gap above the footer.
    expect(onTall, greaterThan(onShorter));
    expect(onShorter, greaterThan(110));
  });

  testWidgets('empty fields are rejected before any request', (tester) async {
    await pumpAt(tester, const Size(393, 873));

    await tester.tap(find.text('LOGIN'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Please enter username'), findsOneWidget);
    expect(find.text('Please enter password'), findsOneWidget);
  });

  testWidgets('password is obscured until the eye is tapped', (tester) async {
    await pumpAt(tester, const Size(393, 873));

    EditableText passwordField() => tester.widgetList<EditableText>(
          find.byType(EditableText),
        ).last;

    expect(passwordField().obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(passwordField().obscureText, isFalse);
  });
}
