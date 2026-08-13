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

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;

    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pump();
  }

  testWidgets('renders its content on a normal phone', (tester) async {
    await pumpAt(tester, const Size(1080, 2400));

    expect(tester.takeException(), isNull);

    expect(find.text('E-Learning @ WWW'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Women in Action'), findsOneWidget);
    // The footer is a RichText, so spans have to be searched explicitly.
    expect(
      find.textContaining('Indev Consultancy', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('App version 1.0'), findsOneWidget);

    // Both inputs are present and usable.
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('lays out without overflow on a short screen', (tester) async {
    await pumpAt(tester, const Size(720, 1100));

    expect(tester.takeException(), isNull);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('lays out without overflow on a tall screen', (tester) async {
    await pumpAt(tester, const Size(1440, 3200));

    expect(tester.takeException(), isNull);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('empty fields are rejected before any request', (tester) async {
    await pumpAt(tester, const Size(1080, 2400));

    await tester.tap(find.text('LOGIN'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Please enter username'), findsOneWidget);
    expect(find.text('Please enter password'), findsOneWidget);
  });

  testWidgets('password is obscured until the eye is tapped', (tester) async {
    await pumpAt(tester, const Size(1080, 2400));

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
