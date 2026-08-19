import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// The photo carousel under the sign-in card: a full-bleed image with its own
/// arrows and page dots underneath, and nothing written over it. It advances on
/// its own every few seconds.
///
/// [slideHeight] is the height of the photo only, set by the caller from the
/// space actually left on screen. It cannot be an Expanded: a PageView is a
/// viewport and cannot be measured intrinsically.
class WomenInActionCard extends StatefulWidget {
  final double slideHeight;

  /// Everything this widget draws other than the photo — the dots and the gap
  /// above them. Callers add this to [slideHeight] to decide whether the
  /// section is worth showing at all. It only has to be close: the photo is
  /// laid out loosely, so an out-of-date estimate costs a few pixels of photo
  /// rather than an overflow.
  static const double chrome = 16;

  const WomenInActionCard({super.key, this.slideHeight = 120});

  @override
  State<WomenInActionCard> createState() => _WomenInActionCardState();
}

class _WomenInActionCardState extends State<WomenInActionCard> {
  static const _dwell = Duration(seconds: 5);
  static const _glide = Duration(milliseconds: 450);

  final _controller = PageController();

  Timer? _timer;
  int _page = 0;

  static const _slides = [
    'assets/images/driver_1.jpg',
    'assets/images/driver_2.jpg',
    'assets/images/driver_3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Auto-advance, restarted on every manual move so a tap is never fighting
  /// the timer.
  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_dwell, (_) => _step(1, manual: false));
  }

  void _step(int delta, {bool manual = true}) {
    if (!mounted || !_controller.hasClients) return;

    var next = _page + delta;

    if (next < 0) next = _slides.length - 1;
    if (next >= _slides.length) next = 0;

    _controller.animateToPage(
      next,
      duration: _glide,
      curve: Curves.easeOutCubic,
    );

    if (manual) _restartTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Loose, so a photo taller than the room left shrinks to fit instead
        // of overflowing the page.
        Flexible(
          child: SizedBox(
            height: widget.slideHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowBrand,
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _slides.length,
                        onPageChanged: (index) =>
                            setState(() => _page = index),
                        itemBuilder: (context, index) => Image.asset(
                          _slides[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppColors.brandGradientRich,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _Arrow(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _step(-1),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _Arrow(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _step(1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _slides.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: i == _page ? 20 : 6,
                decoration: BoxDecoration(
                  color: i == _page
                      ? AppColors.dotActive
                      : AppColors.dotInactive,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _Arrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 34,
            width: 34,
            child: Icon(icon, size: 24, color: AppColors.secondary),
          ),
        ),
      ),
    );
  }
}
