import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../viewmodels/login_view_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  /// Keeps the splash on screen long enough to be read, even when the
  /// session check returns immediately.
  static const _minimumDisplay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();

    _decideNextScreen();
  }

  Future<void> _decideNextScreen() async {
    final results = await Future.wait([
      ref.read(loginViewModelProvider.notifier).restoreSession(),
      Future.delayed(_minimumDisplay).then((_) => true),
    ]);

    if (!mounted) return;

    final hasSession = results.first;

    context.go(hasSession ? AppRoutes.home : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'assets/images/azad_splash.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
