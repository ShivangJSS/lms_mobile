import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../viewmodels/login_view_model.dart';
import '../../viewmodels/password_view_model.dart';
import '../../widgets/women_in_action_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(loginViewModelProvider.notifier).login(
          _usernameController.text.trim(),
          _passwordController.text,
        );

    if (!success || !mounted) return;

    // Straight after sign-in only the two mood questions are asked; the
    // longer questionnaire lives behind Feedback in the side navigation.
    context.go(AppRoutes.moodCheck);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);

    ref.listen<LoginState>(loginViewModelProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;

          // The banner is dropped only when the screen is genuinely too
          // short to hold it; below that the header and card compact instead.
          final showBanner = height >= 780;
          final compact = height < 680;

          // A share of the screen rather than "whatever is left over", so
          // the banner stays a sensible size and the free space can be
          // distributed between the sections instead of piling up under it.
          final slideHeight = (height * 0.20).clamp(110.0, 220.0);

          // No scroll view: the page is pinned to the viewport and the
          // leftover height is shared out by the flexible gaps below.
          return SizedBox(
            height: height,
            child: Column(
              children: [
                _Header(compact: compact),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        // Breathing room under the heading block.
                        const Spacer(flex: 3),
                        _SignInCard(
                          formKey: _formKey,
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          isLoading: loginState.isLoading,
                          compact: compact,
                          onToggleObscure: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          onSubmit: _handleLogin,
                        ),
                        if (showBanner) ...[
                          const Spacer(flex: 3),
                          WomenInActionCard(slideHeight: slideHeight),
                        ],
                        // Smaller share, so the footer sits near the bottom
                        // without a wide empty band above it.
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
                const _Footer(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool compact;

  const _Header({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 0, 24, compact ? 26 : 32),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: compact ? 6 : 10),
            Text(
              'E-Learning @ WWW',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 22 : 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              width: 110,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: compact ? 6 : 8),
            const Text(
              'Learn · Grow · Lead',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignInCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final bool compact;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _SignInCard({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    this.compact = false,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, compact ? 14 : 18, 20, compact ? 10 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              height: compact ? 32 : 40,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.school,
                size: 46,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: compact ? 10 : 16),
            SizedBox(height: compact ? 10 : 14),
            CustomTextField(
              hintText: 'Enter your username',
              controller: usernameController,
              prefixIcon: Icons.person_outline,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter username'
                  : null,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              hintText: 'Enter your password',
              controller: passwordController,
              obscureText: obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade600,
                ),
                onPressed: onToggleObscure,
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter password'
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: AppButton.height,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'LOGIN',
                            style: AppText.button,
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
        child: Column(
          children: [
            const Divider(color: AppColors.divider, height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                children: const [
                  TextSpan(text: 'Tech Partner : '),
                  TextSpan(
                    text: 'Indev Consultancy Pvt Ltd',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'App version 1.0',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
