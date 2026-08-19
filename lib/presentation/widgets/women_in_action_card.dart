import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/glossy.dart';

class _Slide {
  final String image;
  final String title;
  final String subtitle;

  const _Slide(this.image, this.title, this.subtitle);
}

/// The "Women in Action" carousel under the sign-in card.
///
/// [slideHeight] is set by the caller from the space actually left on screen.
/// It cannot be an Expanded: a PageView is a viewport and cannot be measured
/// intrinsically, and the login page sizes itself with IntrinsicHeight.
class WomenInActionCard extends StatefulWidget {
  final double slideHeight;

  const WomenInActionCard({super.key, this.slideHeight = 120});

  @override
  State<WomenInActionCard> createState() => _WomenInActionCardState();
}

class _WomenInActionCardState extends State<WomenInActionCard> {
  final _controller = PageController();

  int _page = 0;

  static const _slides = [
    _Slide(
      'assets/images/traffic_signal.png',
      'Green Signal for Every Woman',
      'Driving change on the road — one licence at a time',
    ),
    _Slide(
      'assets/images/steering_wheel.png',
      'Hands on the Wheel',
      'Skills that turn into independence',
    ),
    _Slide(
      'assets/images/license.png',
      'Licence to Lead',
      'From learner to professional driver',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: AppGloss.card(r: AppGloss.radius),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.brandGradientRich,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Women in Action',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: AppGloss.glass(r: AppGloss.radiusSm),
                          child: const Text(
                            'View all ›',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppGloss.sheen(r: 0),
                ],
              ),
              SizedBox(
                height: widget.slideHeight,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (index) => setState(() => _page = index),
                  itemBuilder: (context, index) => _SlideView(
                    slide: _slides[index],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _slides.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: i == _page ? 18 : 6,
                decoration: BoxDecoration(
                  color: i == _page
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;

  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          slide.image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(Icons.image, size: 40, color: Colors.grey),
            ),
          ),
        ),
        // Keeps the caption legible whatever the photo behind it.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 14,
          right: 14,
          bottom: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slide.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                slide.subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
