import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../viewmodels/login_view_model.dart';
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageWash),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const _Header(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        child: Column(
                          children: [
                            // The card overlaps up into the header for a
                            // layered, glossy feel.
                            Transform.translate(
                              offset: const Offset(0, -28),
                              child: _SignInCard(
                                formKey: _formKey,
                                usernameController: _usernameController,
                                passwordController: _passwordController,
                                obscurePassword: _obscurePassword,
                                isLoading: loginState.isLoading,
                                onToggleObscure: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                onSubmit: _handleLogin,
                                onForgot: () =>
                                    context.push(AppRoutes.forgotPassword),
                              ),
                            ),
                            const WomenInActionCard(slideHeight: 170),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const _Footer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
      decoration: AppGloss.header(r: 36),
      child: Stack(
        children: [
          AppGloss.sheen(r: 36),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 14),
                // Glossy glass badge holding the app mark.
                Container(
                  height: 72,
                  width: 72,
                  decoration: AppGloss.glass(r: 20, opacity: 0.18),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'E-Learning @ WWW',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  width: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Learn · Grow · Lead',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
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
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onForgot;

  const _SignInCard({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onForgot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: AppGloss.card(r: 24, shadow: AppGloss.lifted),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back, please login to continue',
                    textAlign: TextAlign.center,
                    style: AppText.muted.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Username', style: AppText.label),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: 'Enter your username',
              controller: usernameController,
              prefixIcon: Icons.person_outline,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter username'
                  : null,
            ),
            const SizedBox(height: 16),
            const Text('Password', style: AppText.label),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: 'Enter your password',
              controller: passwordController,
              obscureText: obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade600,
                ),
                onPressed: onToggleObscure,
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter password'
                  : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onForgot,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              text: 'LOGIN',
              isLoading: isLoading,
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: onSubmit,
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
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
