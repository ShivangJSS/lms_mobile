import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../viewmodels/login_view_model.dart';

/// The launch screen: the Azad artwork, held while the saved session is
/// checked, then replaced by the dashboard or the login page.
///
/// This is drawn by Flutter rather than by the Android launch theme on
/// purpose. From Android 12 the system draws its own splash over the window
/// background, and it only accepts a small circular masked icon — a full-bleed
/// illustration set as `windowBackground` never appears, which is why the
/// launch screen came up empty. Running the session check here rather than
/// before `runApp` also means the artwork is on screen for the whole wait
/// instead of a blank window.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  /// How long the artwork stays up even when the session check returns at
  /// once, so the launch does not flicker.
  static const _minimumShow = Duration(milliseconds: 1400);

  /// How long the saved session gets before the app opens on the login page
  /// instead.
  ///
  /// The check is a network round trip and Dio allows it 30 seconds — longer
  /// still when the expired-token path spends a refresh and retries. Uncapped,
  /// a backend that is asleep, firewalled or on another network holds the
  /// launch screen for the better part of a minute. A working server answers
  /// this in well under a second.
  static const _sessionBudget = Duration(seconds: 5);

  Timer? _minimumTimer;

  bool _minimumElapsed = false;
  bool _sessionChecked = false;
  bool _hasSession = false;

  @override
  void initState() {
    super.initState();

    // The artwork's minimum time and the session check run together rather
    // than one after the other; whichever finishes last moves the app on.
    _minimumTimer = Timer(_minimumShow, () {
      _minimumElapsed = true;
      _leaveIfReady();
    });

    unawaited(_checkSession());
  }

  @override
  void dispose() {
    _minimumTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkSession() async {
    var hasSession = false;

    try {
      hasSession = await ref
          .read(loginViewModelProvider.notifier)
          .restoreSession()
          .timeout(_sessionBudget, onTimeout: () => false);
    } catch (_) {
      hasSession = false;
    }

    if (!mounted) return;

    _hasSession = hasSession;
    _sessionChecked = true;
    _leaveIfReady();
  }

  void _leaveIfReady() {
    if (!mounted || !_minimumElapsed || !_sessionChecked) return;

    context.go(_hasSession ? AppRoutes.home : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Matches the artwork's paper tone, so the Android launch window and
      // this screen read as one rather than as a flash then a picture.
      backgroundColor: Color(0xFFECE8E7),
      body: SizedBox.expand(
        child: Image(
          image: AssetImage('assets/images/azad_splash.jpg'),
          fit: BoxFit.cover,
          errorBuilder: _fallback,
        ),
      ),
    );
  }

  static Widget _fallback(BuildContext _, Object __, StackTrace? ___) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Image(
          image: AssetImage('assets/images/app_logo.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
