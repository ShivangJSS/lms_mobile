// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../../core/localization/app_strings.dart';
// import '../../../core/routes/app_routes.dart';
// import '../../../core/theme/app_text.dart';
// import '../../../core/theme/colors.dart';
// import '../../../core/theme/glossy.dart';
// import '../../../core/widgets/primary_button.dart';
// import '../../viewmodels/language_view_model.dart';
// import '../../viewmodels/login_view_model.dart';
// import '../../widgets/women_in_action_card.dart';
//
// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//
//   bool _obscurePassword = true;
//
//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final success = await ref.read(loginViewModelProvider.notifier).login(
//           _usernameController.text.trim(),
//           _passwordController.text,
//         );
//
//     if (!success || !mounted) return;
//
//     // Straight after sign-in only the two mood questions are asked; the
//     // longer questionnaire lives behind Feedback in the side navigation.
//     context.go(AppRoutes.moodCheck);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final loginState = ref.watch(loginViewModelProvider);
//     final lang = ref.watch(languageProvider).languageId;
//
//     ref.listen<LoginState>(loginViewModelProvider, (previous, next) {
//       if (next.error != null && next.error!.isNotEmpty) {
//         ScaffoldMessenger.of(context)
//           ..hideCurrentSnackBar()
//           ..showSnackBar(
//             SnackBar(
//               content: Text(next.error!),
//               backgroundColor: AppColors.error,
//               behavior: SnackBarBehavior.floating,
//               margin: const EdgeInsets.all(16),
//             ),
//           );
//       }
//     });
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       // Keep the full-screen layout expanded when the keyboard opens: it
//       // overlays the lower area (fields stay visible) instead of squeezing the
//       // column and overflowing.
//       resizeToAvoidBottomInset: false,
//       body: Container(
//         decoration: const BoxDecoration(gradient: AppColors.pageWash),
//         // Fixed, non-scrolling layout: header and footer take their natural
//         // height and the Women in Action carousel flexes to fill the rest.
//         child: Column(
//           children: [
//             const _Header(),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(
//                   AppSpacing.lg,
//                   0,
//                   AppSpacing.lg,
//                   AppSpacing.sm,
//                 ),
//                 child: Column(
//                   children: [
//                     // The card overlaps up into the header for a layered feel.
//                     Transform.translate(
//                       offset: const Offset(0, -28),
//                       child: _SignInCard(
//                         formKey: _formKey,
//                         usernameController: _usernameController,
//                         passwordController: _passwordController,
//                         obscurePassword: _obscurePassword,
//                         isLoading: loginState.isLoading,
//                         languageId: lang,
//                         onToggleObscure: () => setState(
//                           () => _obscurePassword = !_obscurePassword,
//                         ),
//                         onSubmit: _handleLogin,
//                       ),
//                     ),
//                     const Expanded(child: WomenInActionCard()),
//                   ],
//                 ),
//               ),
//             ),
//             _Footer(languageId: lang),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _Header extends StatelessWidget {
//   const _Header();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
//       decoration: AppGloss.header(),
//       child: ClipRRect(
//         borderRadius: BorderRadius.zero,
//         child: Stack(
//           alignment: Alignment.topCenter,
//           children: [
//             // Soft decorative circles bleeding off the edges.
//             Positioned(top: -50, right: -40, child: _circle(170)),
//             Positioned(bottom: -40, left: -50, child: _circle(150)),
//             // Faint dot grids, echoing the reference art.
//             const Positioned(top: 46, left: 6, child: _DotGrid()),
//             const Positioned(top: 150, right: 6, child: _DotGrid()),
//             SafeArea(
//               bottom: false,
//               child: Column(
//                 children: [
//                   const SizedBox(height: 16),
//                   // White pill badge holding the Azad mark.
//                   Center(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 16,
//                       ),
//                       decoration: BoxDecoration(
//                         // Top-lit gradient + layered shadow so the badge reads
//                         // as a raised, floating 3D chip.
//                         gradient: const LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [Colors.white, Color(0xFFF1EAF6)],
//                         ),
//                         borderRadius: BorderRadius.circular(28),
//                         border: Border.all(color: Colors.white, width: 1),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.28),
//                             blurRadius: 24,
//                             offset: const Offset(0, 12),
//                           ),
//                           BoxShadow(
//                             color:
//                                 const Color(0xFF2A0A26).withValues(alpha: 0.30),
//                             blurRadius: 6,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Image.asset(
//                         'assets/images/app_logo.png',
//                         height: 56,
//                         fit: BoxFit.contain,
//                         errorBuilder: (_, __, ___) => const Icon(
//                           Icons.school_rounded,
//                           color: AppColors.primary,
//                           size: 40,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 18),
//                   const Text(
//                     'E-Learning @ WWW',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 0.2,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   static Widget _circle(double size) {
//     return Container(
//       height: size,
//       width: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.white.withValues(alpha: 0.06),
//       ),
//     );
//   }
// }
//
// /// A small faint 5×5 dot grid used as header decoration.
// class _DotGrid extends StatelessWidget {
//   const _DotGrid();
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: List.generate(
//         5,
//         (_) => Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4),
//           child: Row(
//             children: List.generate(
//               5,
//               (_) => Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 4),
//                 width: 4,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withValues(alpha: 0.16),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _SignInCard extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController usernameController;
//   final TextEditingController passwordController;
//   final bool obscurePassword;
//   final bool isLoading;
//   final int languageId;
//   final VoidCallback onToggleObscure;
//   final VoidCallback onSubmit;
//
//   const _SignInCard({
//     required this.formKey,
//     required this.usernameController,
//     required this.passwordController,
//     required this.obscurePassword,
//     required this.isLoading,
//     required this.languageId,
//     required this.onToggleObscure,
//     required this.onSubmit,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
//       // Deep, layered shadow so the card lifts off the page in 3D.
//       decoration: AppGloss.card(
//         r: 24,
//         shadow: const [
//           BoxShadow(
//             color: Color(0x33000000),
//             blurRadius: 34,
//             offset: Offset(0, 20),
//           ),
//           BoxShadow(
//             color: Color(0x2A4A1444),
//             blurRadius: 14,
//             offset: Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Form(
//         key: formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Text(
//                 AppStrings.of('welcome_back', languageId),
//                 style: const TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 6),
//             Center(
//               child: Text(
//                 AppStrings.of('sign_in_subtitle', languageId),
//                 textAlign: TextAlign.center,
//                 style: AppText.muted.copyWith(fontSize: 14),
//               ),
//             ),
//             const SizedBox(height: 24),
//             _LoginField(
//               hintText: AppStrings.of('username', languageId),
//               controller: usernameController,
//               icon: Icons.person_outline,
//               validator: (value) => value == null || value.trim().isEmpty
//                   ? AppStrings.of('please_enter_username', languageId)
//                   : null,
//             ),
//             const SizedBox(height: 16),
//             _LoginField(
//               hintText: AppStrings.of('password', languageId),
//               controller: passwordController,
//               icon: Icons.lock_outline,
//               obscureText: obscurePassword,
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   obscurePassword
//                       ? Icons.visibility_off_outlined
//                       : Icons.visibility_outlined,
//                   color: AppColors.primary,
//                 ),
//                 onPressed: onToggleObscure,
//               ),
//               validator: (value) => value == null || value.isEmpty
//                   ? AppStrings.of('please_enter_password', languageId)
//                   : null,
//             ),
//             const SizedBox(height: 22),
//             PrimaryButton(
//               text: AppStrings.of('login', languageId),
//               isLoading: isLoading,
//               trailingIcon: Icons.arrow_forward_rounded,
//               onPressed: onSubmit,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// Login text field matching the reference: a rounded white box with a brand
// /// purple leading icon (no divider) that glows on focus.
// class _LoginField extends StatefulWidget {
//   final String hintText;
//   final IconData icon;
//   final TextEditingController controller;
//   final bool obscureText;
//   final Widget? suffixIcon;
//   final String? Function(String?)? validator;
//
//   const _LoginField({
//     required this.hintText,
//     required this.icon,
//     required this.controller,
//     this.obscureText = false,
//     this.suffixIcon,
//     this.validator,
//   });
//
//   @override
//   State<_LoginField> createState() => _LoginFieldState();
// }
//
// class _LoginFieldState extends State<_LoginField> {
//   final _focusNode = FocusNode();
//   bool _focused = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _focusNode.addListener(() {
//       if (_focusNode.hasFocus != _focused) {
//         setState(() => _focused = _focusNode.hasFocus);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 160),
//       curve: Curves.easeOut,
//       decoration: BoxDecoration(
//         // Subtle top-lit gradient reads as a gently raised surface.
//         gradient: const LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Colors.white, Color(0xFFF4EEF8)],
//         ),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: _focused ? AppColors.primary : Colors.white,
//           width: _focused ? 1.6 : 1,
//         ),
//         boxShadow: [
//           if (_focused)
//             BoxShadow(
//               color: AppColors.primary.withValues(alpha: 0.22),
//               blurRadius: 16,
//               offset: const Offset(0, 6),
//             )
//           else ...[
//             const BoxShadow(
//               color: Color(0x1F000000),
//               blurRadius: 12,
//               offset: Offset(0, 6),
//             ),
//             // Top highlight for the extruded 3D edge.
//             const BoxShadow(
//               color: Colors.white,
//               blurRadius: 2,
//               offset: Offset(0, -1),
//             ),
//           ],
//         ],
//       ),
//       child: Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 16, right: 12),
//             child: Icon(widget.icon, size: 22, color: AppColors.primary),
//           ),
//           Expanded(
//             child: TextFormField(
//               controller: widget.controller,
//               focusNode: _focusNode,
//               obscureText: widget.obscureText,
//               validator: widget.validator,
//               style: const TextStyle(
//                 fontSize: 15,
//                 color: AppColors.textPrimary,
//               ),
//               decoration: InputDecoration(
//                 hintText: widget.hintText,
//                 hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
//                 // IMPORTANT: don't let TextFormField paint its own background.
//                 filled: false,
//                 fillColor: Colors.transparent,
//                 isDense: true,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 18),
//                 border: InputBorder.none,
//                 enabledBorder: InputBorder.none,
//                 focusedBorder: InputBorder.none,
//                 errorBorder: InputBorder.none,
//                 focusedErrorBorder: InputBorder.none,
//               ),
//             ),
//           ),
//           if (widget.suffixIcon != null) widget.suffixIcon!,
//         ],
//       ),
//     );
//   }
// }
//
// class _Footer extends StatelessWidget {
//   final int languageId;
//
//   const _Footer({required this.languageId});
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       top: false,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               height: 40,
//               width: 40,
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withValues(alpha: 0.08),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.handshake_outlined,
//                 color: AppColors.primary,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Flexible(
//               child: RichText(
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 text: TextSpan(
//                   style: TextStyle(color: Colors.grey.shade800, fontSize: 15),
//                   children: [
//                     TextSpan(
//                         text:
//                             '${AppStrings.of('tech_partner', languageId)} : '),
//                     const TextSpan(
//                       text: 'Indev Consultancy Pvt Ltd',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';
import '../../../core/widgets/primary_button.dart';
import '../../viewmodels/language_view_model.dart';
import '../../viewmodels/login_view_model.dart';
import '../../widgets/women_in_action_card.dart';

/// Page background: one deep, solid-feeling purple from top to bottom
/// (matches the reference screenshots).
const _pageBackground = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF5E0B5B), Color(0xFF4A0848)],
);

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
    final lang = ref.watch(languageProvider).languageId;

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Light status-bar icons on the dark purple page.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF4A0848),
        // Keyboard overlays the lower area instead of squeezing the column.
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(gradient: _pageBackground),
          // Fixed, non-scrolling layout: header, card and footer take their
          // natural height; the Women in Action carousel fills the rest.
          child: Column(
            children: [
              const _Header(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      _SignInCard(
                        formKey: _formKey,
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        isLoading: loginState.isLoading,
                        languageId: lang,
                        onToggleObscure: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        onSubmit: _handleLogin,
                      ),
                      const SizedBox(height: 20),
                      const Expanded(child: WomenInActionCard()),
                    ],
                  ),
                ),
              ),
              _Footer(languageId: lang),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo + title straight on the purple page: no badge, no decorations.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
        child: Column(
          children: [
            // The logo is shown as a clean white mark. If your asset is
            // already white you can drop the ColorFiltered wrapper.
            ColorFiltered(
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: Image.asset(
                'assets/images/app_logo.png',
                height: 72,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'E-Learning @ WWW',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
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
  final int languageId;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _SignInCard({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.languageId,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                AppStrings.of('welcome_back', languageId),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A0848),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                AppStrings.of('sign_in_subtitle', languageId),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3A1137),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _LoginField(
              hintText: AppStrings.of('username', languageId),
              controller: usernameController,
              icon: Icons.person_outline,
              validator: (value) => value == null || value.trim().isEmpty
                  ? AppStrings.of('please_enter_username', languageId)
                  : null,
            ),
            const SizedBox(height: 16),
            _LoginField(
              hintText: AppStrings.of('password', languageId),
              controller: passwordController,
              icon: Icons.lock_outline,
              obscureText: obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.primary,
                ),
                onPressed: onToggleObscure,
              ),
              validator: (value) => value == null || value.isEmpty
                  ? AppStrings.of('please_enter_password', languageId)
                  : null,
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              text: AppStrings.of('login', languageId),
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

/// Flat white, rounded field with a thin grey outline and a purple leading
/// icon. The outline turns purple when focused.
class _LoginField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _LoginField({
    required this.hintText,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  State<_LoginField> createState() => _LoginFieldState();
}

class _LoginFieldState extends State<_LoginField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus != _focused) {
        setState(() => _focused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focused ? AppColors.primary : const Color(0xFFDCD3DE),
          width: _focused ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(widget.icon, size: 22, color: AppColors.primary),
          ),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              validator: widget.validator,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF4A0848),
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF5E2A5B),
                  fontSize: 16,
                ),
                filled: false,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            ),
          ),
          if (widget.suffixIcon != null) widget.suffixIcon!,
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final int languageId;

  const _Footer({required this.languageId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFD9BFD8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.handshake_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 15,
                  ),
                  children: [
                    TextSpan(
                      text: '${AppStrings.of('tech_partner', languageId)} : ',
                    ),
                    const TextSpan(
                      text: 'Indev Consultancy Pvt Ltd',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../../core/localization/app_strings.dart';
// import '../../../core/routes/app_routes.dart';
// import '../../../core/theme/app_text.dart';
// import '../../../core/theme/colors.dart';
// import '../../../core/theme/glossy.dart';
// import '../../../core/widgets/primary_button.dart';
// import '../../viewmodels/language_view_model.dart';
// import '../../viewmodels/login_view_model.dart';
// import '../../widgets/women_in_action_card.dart';
//
// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//
//   bool _obscurePassword = true;
//
//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final success = await ref.read(loginViewModelProvider.notifier).login(
//           _usernameController.text.trim(),
//           _passwordController.text,
//         );
//
//     if (!success || !mounted) return;
//
//     context.go(AppRoutes.moodCheck);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final loginState = ref.watch(loginViewModelProvider);
//     final lang = ref.watch(languageProvider).languageId;
//
//     ref.listen<LoginState>(loginViewModelProvider, (previous, next) {
//       if (next.error != null && next.error!.isNotEmpty) {
//         ScaffoldMessenger.of(context)
//           ..hideCurrentSnackBar()
//           ..showSnackBar(
//             SnackBar(
//               content: Text(next.error!),
//               backgroundColor: AppColors.error,
//               behavior: SnackBarBehavior.floating,
//               margin: const EdgeInsets.all(16),
//             ),
//           );
//       }
//     });
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF4A1043),
//       resizeToAvoidBottomInset: false,
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF5C1854),
//               Color(0xFF430E3D),
//               Color(0xFF2E072A),
//             ],
//             stops: [0.0, 0.55, 1.0],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
//             child: Column(
//               children: [
//                 const SizedBox(height: 12),
//                 const _Header(),
//                 const SizedBox(height: 16),
//                 _SignInCard(
//                   formKey: _formKey,
//                   usernameController: _usernameController,
//                   passwordController: _passwordController,
//                   obscurePassword: _obscurePassword,
//                   isLoading: loginState.isLoading,
//                   languageId: lang,
//                   onToggleObscure: () => setState(
//                     () => _obscurePassword = !_obscurePassword,
//                   ),
//                   onSubmit: _handleLogin,
//                 ),
//                 const SizedBox(height: 16),
//                 const Expanded(child: WomenInActionCard()),
//                 _Footer(languageId: lang),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _Header extends StatelessWidget {
//   const _Header();
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Center(
//           child: Image.asset(
//             'assets/images/app_logo.png',
//             height: 52,
//             fit: BoxFit.contain,
//             errorBuilder: (_, __, ___) => const Icon(
//               Icons.school_rounded,
//               color: Colors.white,
//               size: 44,
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         const Text(
//           'E-Learning @ WWW',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 0.3,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _SignInCard extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController usernameController;
//   final TextEditingController passwordController;
//   final bool obscurePassword;
//   final bool isLoading;
//   final int languageId;
//   final VoidCallback onToggleObscure;
//   final VoidCallback onSubmit;
//
//   const _SignInCard({
//     required this.formKey,
//     required this.usernameController,
//     required this.passwordController,
//     required this.obscurePassword,
//     required this.isLoading,
//     required this.languageId,
//     required this.onToggleObscure,
//     required this.onSubmit,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x40000000),
//             blurRadius: 32,
//             offset: Offset(0, 16),
//           ),
//           BoxShadow(
//             color: Color(0x203A0A35),
//             blurRadius: 12,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Form(
//         key: formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Center(
//               child: Text(
//                 AppStrings.of('welcome_back', languageId),
//                 style: const TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 6),
//             Center(
//               child: Text(
//                 AppStrings.of('sign_in_subtitle', languageId),
//                 textAlign: TextAlign.center,
//                 style: AppText.muted.copyWith(fontSize: 14),
//               ),
//             ),
//             const SizedBox(height: 22),
//             _LoginField(
//               hintText: AppStrings.of('username', languageId),
//               controller: usernameController,
//               icon: Icons.person_outline,
//               validator: (value) => value == null || value.trim().isEmpty
//                   ? AppStrings.of('please_enter_username', languageId)
//                   : null,
//             ),
//             const SizedBox(height: 14),
//             _LoginField(
//               hintText: AppStrings.of('password', languageId),
//               controller: passwordController,
//               icon: Icons.lock_outline,
//               obscureText: obscurePassword,
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   obscurePassword
//                       ? Icons.visibility_off_outlined
//                       : Icons.visibility_outlined,
//                   color: AppColors.primary,
//                 ),
//                 onPressed: onToggleObscure,
//               ),
//               validator: (value) => value == null || value.isEmpty
//                   ? AppStrings.of('please_enter_password', languageId)
//                   : null,
//             ),
//             const SizedBox(height: 22),
//             PrimaryButton(
//               text: AppStrings.of('login', languageId),
//               isLoading: isLoading,
//               trailingIcon: Icons.arrow_forward_rounded,
//               onPressed: onSubmit,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _LoginField extends StatefulWidget {
//   final String hintText;
//   final IconData icon;
//   final TextEditingController controller;
//   final bool obscureText;
//   final Widget? suffixIcon;
//   final String? Function(String?)? validator;
//
//   const _LoginField({
//     required this.hintText,
//     required this.icon,
//     required this.controller,
//     this.obscureText = false,
//     this.suffixIcon,
//     this.validator,
//   });
//
//   @override
//   State<_LoginField> createState() => _LoginFieldState();
// }
//
// class _LoginFieldState extends State<_LoginField> {
//   final _focusNode = FocusNode();
//   bool _focused = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _focusNode.addListener(() {
//       if (_focusNode.hasFocus != _focused) {
//         setState(() => _focused = _focusNode.hasFocus);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 160),
//       curve: Curves.easeOut,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Colors.white, Color(0xFFF6EEF8)],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: _focused ? AppColors.primary : const Color(0xFFE2D2E6),
//           width: _focused ? 1.6 : 1,
//         ),
//         boxShadow: [
//           if (_focused)
//             BoxShadow(
//               color: AppColors.primary.withValues(alpha: 0.20),
//               blurRadius: 14,
//               offset: const Offset(0, 5),
//             )
//           else ...[
//             const BoxShadow(
//               color: Color(0x14000000),
//               blurRadius: 10,
//               offset: Offset(0, 4),
//             ),
//             const BoxShadow(
//               color: Colors.white,
//               blurRadius: 2,
//               offset: Offset(0, -1),
//             ),
//           ],
//         ],
//       ),
//       child: Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 16, right: 12),
//             child: Icon(widget.icon, size: 22, color: AppColors.primary),
//           ),
//           Expanded(
//             child: TextFormField(
//               controller: widget.controller,
//               focusNode: _focusNode,
//               obscureText: widget.obscureText,
//               validator: widget.validator,
//               style: const TextStyle(
//                 fontSize: 15,
//                 color: AppColors.textPrimary,
//               ),
//               decoration: InputDecoration(
//                 hintText: widget.hintText,
//                 hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
//                 filled: false,
//                 fillColor: Colors.transparent,
//                 isDense: true,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 16),
//                 border: InputBorder.none,
//                 enabledBorder: InputBorder.none,
//                 focusedBorder: InputBorder.none,
//                 errorBorder: InputBorder.none,
//                 focusedErrorBorder: InputBorder.none,
//               ),
//             ),
//           ),
//           if (widget.suffixIcon != null) widget.suffixIcon!,
//         ],
//       ),
//     );
//   }
// }
//
// class _Footer extends StatelessWidget {
//   final int languageId;
//
//   const _Footer({required this.languageId});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             height: 32,
//             width: 32,
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha: 0.18),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.handshake_outlined,
//               color: Colors.white,
//               size: 18,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Flexible(
//             child: RichText(
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               text: TextSpan(
//                 style: const TextStyle(color: Colors.white70, fontSize: 13.5),
//                 children: [
//                   TextSpan(
//                     text: '${AppStrings.of('tech_partner', languageId)} : ',
//                   ),
//                   const TextSpan(
//                     text: 'Indev Consultancy Pvt Ltd',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFFE5B2E2),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
