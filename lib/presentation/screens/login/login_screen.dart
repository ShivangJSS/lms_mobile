import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../viewmodels/login_view_model.dart';
import '../../widgets/women_in_action_card.dart';

/// The sign-in page.
///
/// It is deliberately a single, unscrollable page: everything is sized from the
/// height actually available (see [_Metrics]), the carousel takes whatever is
/// left over, and it is dropped only when the screen is too short to hold it.
/// Nothing here is allowed to introduce a scroll view.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _entrance;

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
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
      // The page is pinned to the viewport, so the keyboard must slide over it
      // instead of shrinking it — resizing would have nowhere to put the
      // difference without a scroll view.
      resizeToAvoidBottomInset: false,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.pageWash),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final m = _Metrics.of(constraints.biggest);

            return Column(
              children: [
                _Rise(
                  animation: _entrance,
                  start: 0.0,
                  child: _Header(m: m),
                ),
                Expanded(
                  // Lifts the card up into the header for the layered look.
                  // Shifting the whole block (rather than the card alone) keeps
                  // the gap it leaves behind at the bottom, where the flexible
                  // carousel absorbs it.
                  child: Transform.translate(
                    offset: Offset(0, -m.overlap),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        m.pagePad,
                        0,
                        m.pagePad,
                        m.pagePad + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Column(
                        children: [
                          _Rise(
                            animation: _entrance,
                            start: 0.15,
                            child: _SignInCard(
                              m: m,
                              formKey: _formKey,
                              usernameController: _usernameController,
                              passwordController: _passwordController,
                              obscurePassword: _obscurePassword,
                              rememberMe: _rememberMe,
                              isLoading: loginState.isLoading,
                              onToggleObscure: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              onToggleRemember: () => setState(
                                () => _rememberMe = !_rememberMe,
                              ),
                              onSubmit: _handleLogin,
                            ),
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, box) {
                                final slide =
                                    box.maxHeight - WomenInActionCard.chrome;

                                if (!m.showBanner ||
                                    slide < _Metrics.minSlide) {
                                  return const SizedBox.shrink();
                                }

                                return _Rise(
                                  animation: _entrance,
                                  start: 0.3,
                                  child: WomenInActionCard(
                                    slideHeight: math.min(
                                      slide,
                                      _Metrics.maxSlide,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Entrance animation
// -----------------------------------------------------------------------------

/// Fades a block in while sliding it up a little. [start] staggers it along the
/// shared controller, so the header, card and carousel arrive in order.
class _Rise extends StatelessWidget {
  final Animation<double> animation;
  final double start;
  final Widget child;

  const _Rise({
    required this.animation,
    required this.start,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, inner) => Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - curved.value)),
          child: inner,
        ),
      ),
      child: child,
    );
  }
}

// -----------------------------------------------------------------------------
// Sizing
// -----------------------------------------------------------------------------

/// Every size on the page, interpolated between a compact phone and a tall one.
///
/// The page cannot scroll, so nothing here is a fixed number: [t] runs from 0
/// on the shortest phone we support to 1 on a tall one, and every measurement
/// is read off it. The design system's proportions hold at every step; only the
/// absolute values shrink, because its literal sizes add up to roughly 950pt
/// against the 752pt a 360x800 phone actually has once the navigation bar is
/// taken off.
class _Metrics {
  /// Below this the carousel is dropped rather than squeezed.
  static const double bannerFloor = 660;

  /// A photo shorter than this reads as a strip, so the carousel goes instead.
  static const double minSlide = 64;

  /// Past this the photo stops growing and the space goes to the gaps.
  static const double maxSlide = 260;

  final double width;
  final double height;
  final double t;

  const _Metrics._(this.width, this.height, this.t);

  factory _Metrics.of(Size size) {
    return _Metrics._(
      size.width,
      size.height,
      ((size.height - 620) / 280).clamp(0.0, 1.0),
    );
  }

  double _l(double compact, double tall) => compact + (tall - compact) * t;

  bool get showBanner => height >= bannerFloor;

  /// The badge above "Welcome Back!" is the first thing to go when the screen
  /// is too short for it, then the line under the greeting.
  bool get showAvatar => height >= 620;

  bool get showSubtitle => height >= 600;

  bool get dense => t < 0.62;

  double get pagePad => _l(14, 20);
  double get overlap => _l(10, 16);

  // ---------------------------------------------------------------- header
  /// The design system asks for 22% of the screen. On a short phone that is
  /// not enough for the logo plate plus two lines of type, so it is a floor
  /// rather than a fixed share.
  double get headerHeight =>
      math.max(height * 0.22, _minHeaderHeight) + overlap;

  double get _minHeaderHeight => _l(130, 190);

  double get headerTopPad => _l(0, 6);

  /// The logo plate is 240x72 in the design; it is sized off the screen width
  /// so the mark keeps the same presence on a narrower phone.
  double get logoPlateWidth => math.min(width * _l(0.58, 0.66), 240);

  double get logoPlateHeight => _l(46, 72);
  double get logoPlateRadius => 24;
  double get portalTitleSize => _l(16, 22);
  double get taglineSize => _l(10.5, 14);
  double get headerBottomPad => _l(6, 18);
  double get headerRadius => 32;

  // ------------------------------------------------------------------ card
  double get cardRadius => 32;
  double get cardPadH => _l(16, 24);
  double get cardPadV => _l(5, 12);
  double get badgeSize => _l(20, 38);
  double get welcomeSize => _l(14, 20);
  double get subtitleSize => _l(10, 13);
  double get labelSize => _l(11, 14);
  double get buttonHeight => _l(34, 46);

  double get gapXs => _l(1, 4);
  double get gapSm => _l(2, 5);
  double get gapMd => _l(3, 8);
  double get gapLg => _l(4, 11);

}

// -----------------------------------------------------------------------------
// Header
// -----------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final _Metrics m;

  const _Header({required this.m});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: m.headerHeight,
      // Nothing the header paints may spill past its rounded bottom onto the
      // card below it.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientRich,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(m.headerRadius),
          bottomRight: Radius.circular(m.headerRadius),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBrand,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _HeaderWavePainter()),
            ),
          ),
          const Positioned.fill(child: _HeaderDoodles()),
          // Full width on purpose. A Stack lays its non-positioned children out
          // loosely, so without this the column shrink-wraps to its widest
          // child and gets pinned to the top-left instead of centred.
          SizedBox(
            width: double.infinity,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  m.headerTopPad,
                  20,
                  m.headerBottomPad,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // The logo sits on its own white plate, the way it does on
                    // Azad's own material.
                    Container(
                      width: m.logoPlateWidth,
                      height: m.logoPlateHeight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(m.logoPlateRadius),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x332E1065),
                            blurRadius: 20,
                            spreadRadius: 1,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.school_rounded,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                    ),
                    SizedBox(height: m.gapMd),
                    // Wrapping is not an option on a page with no slack: long
                    // translations and large system font scales shrink instead.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'E-Learning Portal',
                        maxLines: 1,
                        style: AppTypography.portalTitle.copyWith(
                          fontSize: m.portalTitleSize,
                        ),
                      ),
                    ),
                    SizedBox(height: m.gapXs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _Tagline(size: m.taglineSize),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Learn • Grow • Empower", with the dots between the words.
class _Tagline extends StatelessWidget {
  final double size;

  const _Tagline({required this.size});

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.tagline.copyWith(fontSize: size);

    Widget dot() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Container(
            height: 5,
            width: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              shape: BoxShape.circle,
            ),
          ),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Learn', style: style),
        dot(),
        Text('Grow', style: style),
        dot(),
        Text('Empower', style: style),
      ],
    );
  }
}

/// The pale curved bands sweeping across the header, which is what gives it
/// depth rather than reading as a flat block of purple.
class _HeaderWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pale = Paint()..color = const Color(0x1FFFFFFF);
    final paler = Paint()..color = const Color(0x14FFFFFF);

    // A broad arc rising from the bottom-left.
    canvas.drawCircle(
      Offset(size.width * 0.06, size.height * 1.06),
      size.height * 0.86,
      pale,
    );

    // A second, shallower one crossing it from the right.
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 1.24),
      size.height * 0.9,
      paler,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The faint education icons and dot grids in the header corners, at the 10%
/// opacity the design system asks for.
class _HeaderDoodles extends StatelessWidget {
  const _HeaderDoodles();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Placed as a fraction of the header so they stay inside it on a
          // short screen instead of landing on the sign-in card.
          final h = constraints.maxHeight;
          final w = constraints.maxWidth;

          return Stack(
            children: [
              Positioned(
                left: 10,
                top: h * 0.30,
                child: Icon(
                  Icons.school_outlined,
                  size: h * 0.30,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              Positioned(
                right: 10,
                top: h * 0.26,
                child: Icon(
                  Icons.menu_book_outlined,
                  size: h * 0.30,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              Positioned(
                left: 8,
                top: h * 0.06,
                child: CustomPaint(
                  size: Size(w * 0.22, h * 0.20),
                  painter: _DotGridPainter(),
                ),
              ),
              Positioned(
                right: 8,
                bottom: h * 0.10,
                child: CustomPaint(
                  size: Size(w * 0.20, h * 0.18),
                  painter: _DotGridPainter(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.18);

    const step = 14.0;

    for (var y = 0.0; y < size.height; y += step) {
      for (var x = 0.0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.7, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// Sign-in card
// -----------------------------------------------------------------------------

class _SignInCard extends StatelessWidget {
  final _Metrics m;
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final bool isLoading;
  final VoidCallback onToggleObscure;
  final VoidCallback onToggleRemember;
  final VoidCallback onSubmit;

  const _SignInCard({
    required this.m,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isLoading,
    required this.onToggleObscure,
    required this.onToggleRemember,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: m.cardPadH,
        vertical: m.cardPadV,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(m.cardRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBrand,
            blurRadius: 40,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.showAvatar) ...[
              Center(
                child: Container(
                  height: m.badgeSize,
                  width: m.badgeSize,
                  decoration: const BoxDecoration(
                    color: AppColors.badgeWash,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: m.badgeSize * 0.5,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              SizedBox(height: m.gapSm),
            ],
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Welcome Back!',
                  maxLines: 1,
                  style: AppTypography.welcome.copyWith(
                    fontSize: m.welcomeSize,
                  ),
                ),
              ),
            ),
            if (m.showSubtitle) ...[
              SizedBox(height: m.gapXs),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Sign in to continue your learning journey',
                    maxLines: 1,
                    style: AppTypography.welcomeSubtitle.copyWith(
                      fontSize: m.subtitleSize,
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: m.gapLg),
            Text(
              'Username',
              style: AppTypography.inputLabel.copyWith(fontSize: m.labelSize),
            ),
            SizedBox(height: m.gapSm),
            CustomTextField(
              hintText: 'Enter your username',
              controller: usernameController,
              prefixIcon: Icons.person_outline,
              dense: m.dense,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter username'
                  : null,
            ),
            SizedBox(height: m.gapMd),
            Text(
              'Password',
              style: AppTypography.inputLabel.copyWith(fontSize: m.labelSize),
            ),
            SizedBox(height: m.gapSm),
            CustomTextField(
              hintText: 'Enter your password',
              controller: passwordController,
              obscureText: obscurePassword,
              prefixIcon: Icons.lock_outline,
              dense: m.dense,
              suffixIcon: IconButton(
                iconSize: 21,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 46, minHeight: 40),
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.secondary,
                ),
                onPressed: onToggleObscure,
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter password'
                  : null,
            ),
            SizedBox(height: m.gapSm),
            _RememberMe(checked: rememberMe, onTap: onToggleRemember),
            SizedBox(height: m.gapSm),
            GradientButton(
              text: 'LOGIN',
              height: m.buttonHeight,
              isLoading: isLoading,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _RememberMe extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;

  const _RememberMe({required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                color: checked ? AppColors.secondary : AppColors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: checked ? AppColors.secondary : AppColors.hairline,
                  width: 1.6,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 15, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Remember me',
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: AppTypography.family,
                    fontFamilyFallback: AppTypography.fallback,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
