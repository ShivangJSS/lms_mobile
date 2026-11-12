// import 'package:flutter/material.dart';
//
// import '../../core/theme/colors.dart';
// import '../../core/theme/glossy.dart';
//
// class _Slide {
//   final String image;
//   final String title;
//   final String subtitle;
//
//   const _Slide(this.image, this.title, this.subtitle);
// }
//
// /// The "Women in Action" carousel under the sign-in card.
// ///
// /// The card fills whatever height its parent gives it (place it inside an
// /// [Expanded]/[Flexible]); the slide viewport takes all the room left after
// /// the header strip and the page dots.
// class WomenInActionCard extends StatefulWidget {
//   const WomenInActionCard({super.key});
//
//   @override
//   State<WomenInActionCard> createState() => _WomenInActionCardState();
// }
//
// class _WomenInActionCardState extends State<WomenInActionCard> {
//   final _controller = PageController();
//
//   int _page = 0;
//
//   static const _slides = [
//     _Slide(
//       'assets/images/traffic_signal.png',
//       'Green Signal for Every Woman',
//       'Driving change on the road — one licence at a time',
//     ),
//     _Slide(
//       'assets/images/steering_wheel.png',
//       'Hands on the Wheel',
//       'Skills that turn into independence',
//     ),
//     _Slide(
//       'assets/images/license.png',
//       'Licence to Lead',
//       'From learner to professional driver',
//     ),
//   ];
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: Container(
//             // Lifted, layered shadow to match the 3D depth of the sign-in card.
//             decoration: AppGloss.card(
//               r: AppGloss.radius,
//               shadow: const [
//                 BoxShadow(
//                   color: Color(0x2E000000),
//                   blurRadius: 26,
//                   offset: Offset(0, 14),
//                 ),
//                 BoxShadow(
//                   color: Color(0x1F4A1444),
//                   blurRadius: 10,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             clipBehavior: Clip.antiAlias,
//             child: Column(
//               children: [
//                 // Purple header strip — "View all" removed per request.
//                 Stack(
//                   children: [
//                     Container(
//                       decoration: const BoxDecoration(
//                         gradient: AppColors.brandGradientRich,
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 12,
//                       ),
//                       child: const Row(
//                         children: [
//                           Icon(
//                             Icons.person_outline,
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                           SizedBox(width: 8),
//                           Text(
//                             'Women in Action',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     AppGloss.sheen(r: 0),
//                   ],
//                 ),
//                 Expanded(
//                   child: PageView.builder(
//                     controller: _controller,
//                     itemCount: _slides.length,
//                     onPageChanged: (index) => setState(() => _page = index),
//                     itemBuilder: (context, index) => _SlideView(
//                       slide: _slides[index],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             for (var i = 0; i < _slides.length; i++)
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 margin: const EdgeInsets.symmetric(horizontal: 3),
//                 height: 6,
//                 width: i == _page ? 18 : 6,
//                 decoration: BoxDecoration(
//                   color: i == _page
//                       ? AppColors.primary
//                       : AppColors.primary.withValues(alpha: 0.25),
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// class _SlideView extends StatelessWidget {
//   final _Slide slide;
//
//   const _SlideView({required this.slide});
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         Image.asset(
//           slide.image,
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => Container(
//             color: Colors.grey.shade300,
//             child: const Center(
//               child: Icon(Icons.image, size: 40, color: Colors.grey),
//             ),
//           ),
//         ),
//         // Keeps the caption legible whatever the photo behind it.
//         Positioned.fill(
//           child: DecoratedBox(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.center,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.transparent,
//                   Colors.black.withValues(alpha: 0.65),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Positioned(
//           left: 14,
//           right: 14,
//           bottom: 12,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 slide.title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 slide.subtitle,
//                 style: const TextStyle(color: Colors.white70, fontSize: 12),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';

class _Slide {
  final String image;
  final String title;
  final String subtitle;

  const _Slide(this.image, this.title, this.subtitle);
}

/// The "Women in Action" carousel under the sign-in card.
///
/// Full-bleed photo slides with auto-scrolling every 4 seconds.
class WomenInActionCard extends StatefulWidget {
  const WomenInActionCard({super.key});

  @override
  State<WomenInActionCard> createState() => _WomenInActionCardState();
}

class _WomenInActionCardState extends State<WomenInActionCard> {
  final _controller = PageController();

  Timer? _autoScrollTimer;
  int _page = 0;

  static const _slides = [
    _Slide(
      'assets/images/img_3.png',
      'Green Signal for Every Woman',
      'Driving change on the road — one licence at a time',
    ),
    _Slide(
      'assets/images/img_2.png',
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
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(
      const Duration(seconds: 4),
      (timer) {
        if (!mounted) return;

        final nextPage = (_page + 1) % _slides.length;

        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  void _onPageChanged(int index) {
    setState(() => _page = index);

    // Reset auto-scroll timer on manual swipe.
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) =>
                      _SlideView(slide: _slides[index]),
                ),
                // Fixed label on top of every slide (does not swipe away).
                const Positioned(
                  top: 10,
                  left: 10,
                  child: IgnorePointer(child: _LabelChip()),
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
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: i == _page ? 20 : 6,
                decoration: BoxDecoration(
                  color: i == _page
                      ? const Color(0xFFD9BFD8)
                      : Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text(
            'Women in Action',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(Icons.image, size: 40, color: Colors.grey),
            ),
          ),
        ),
        // Bottom scrim keeps the caption readable on any photo.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                slide.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                slide.subtitle,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
//
// class _Slide {
//   final String image;
//   final String title;
//   final String subtitle;
//
//   const _Slide(this.image, this.title, this.subtitle);
// }
//
// /// The "Women in Action" carousel under the sign-in card.
// ///
// /// Full-bleed photo slides with a "Women in Action" chip at the top-left and
// /// the caption at the bottom-left. Fills whatever height its parent gives it
// /// (place it inside an [Expanded]); page dots sit underneath, on the purple
// /// page background.
// class WomenInActionCard extends StatefulWidget {
//   const WomenInActionCard({super.key});
//
//   @override
//   State<WomenInActionCard> createState() => _WomenInActionCardState();
// }
//
// class _WomenInActionCardState extends State<WomenInActionCard> {
//   final _controller = PageController();
//
//   int _page = 0;
//
//   static const _slides = [
//     _Slide(
//       'assets/images/img_3.png',
//       'Green Signal for Every Woman',
//       'Driving change on the road — one licence at a time',
//     ),
//     _Slide(
//       'assets/images/img_2.png',
//       'Hands on the Wheel',
//       'Skills that turn into independence',
//     ),
//     _Slide(
//       'assets/images/license.png',
//       'Licence to Lead',
//       'From learner to professional driver',
//     ),
//   ];
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.28),
//                   blurRadius: 22,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             clipBehavior: Clip.antiAlias,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 PageView.builder(
//                   controller: _controller,
//                   itemCount: _slides.length,
//                   onPageChanged: (index) => setState(() => _page = index),
//                   itemBuilder: (context, index) =>
//                       _SlideView(slide: _slides[index]),
//                 ),
//                 // Fixed label on top of every slide (does not swipe away).
//                 const Positioned(
//                   top: 10,
//                   left: 10,
//                   child: IgnorePointer(child: _LabelChip()),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             for (var i = 0; i < _slides.length; i++)
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 margin: const EdgeInsets.symmetric(horizontal: 3),
//                 height: 6,
//                 width: i == _page ? 20 : 6,
//                 decoration: BoxDecoration(
//                   color: i == _page
//                       ? const Color(0xFFD9BFD8)
//                       : Colors.white.withValues(alpha: 0.35),
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// class _LabelChip extends StatelessWidget {
//   const _LabelChip();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.black.withValues(alpha: 0.28),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: const Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.person_outline, color: Colors.white, size: 18),
//           SizedBox(width: 8),
//           Text(
//             'Women in Action',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _SlideView extends StatelessWidget {
//   final _Slide slide;
//
//   const _SlideView({required this.slide});
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         Image.asset(
//           slide.image,
//           fit: BoxFit.cover,
//           alignment: Alignment.center,
//           filterQuality: FilterQuality.high,
//           errorBuilder: (_, __, ___) => Container(
//             color: Colors.grey.shade300,
//             child: const Center(
//               child: Icon(Icons.image, size: 40, color: Colors.grey),
//             ),
//           ),
//         ),
//         // Bottom scrim keeps the caption readable on any photo.
//         Positioned.fill(
//           child: DecoratedBox(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.center,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.transparent,
//                   Colors.black.withValues(alpha: 0.7),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Positioned(
//           left: 16,
//           right: 16,
//           bottom: 14,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 slide.title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 slide.subtitle,
//                 style: const TextStyle(color: Colors.white, fontSize: 13),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

//
//
// import 'dart:async';
//
// import 'package:flutter/material.dart';
//
// import '../../core/theme/colors.dart';
// import '../../core/theme/glossy.dart';
//
// class _Slide {
//   final String image;
//   final String title;
//   final String subtitle;
//
//   const _Slide(this.image, this.title, this.subtitle);
// }
//
// /// The "Women in Action" carousel under the sign-in card.
// class WomenInActionCard extends StatefulWidget {
//   const WomenInActionCard({super.key});
//
//   @override
//   State<WomenInActionCard> createState() => _WomenInActionCardState();
// }
//
// class _WomenInActionCardState extends State<WomenInActionCard> {
//   final _controller = PageController();
//
//   Timer? _autoScrollTimer;
//   int _page = 0;
//
//   static const _slides = [
//     _Slide(
//       'assets/images/license.png',
//       'Licence to Lead',
//       'From learner to professional driver',
//     ),
//     _Slide(
//       'assets/images/traffic_signal.png',
//       'Green Signal for Every Woman',
//       'Driving change on the road — one licence at a time',
//     ),
//     _Slide(
//       'assets/images/steering_wheel.png',
//       'Hands on the Wheel',
//       'Skills that turn into independence',
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _startAutoScroll();
//   }
//
//   void _startAutoScroll() {
//     _autoScrollTimer?.cancel();
//
//     _autoScrollTimer = Timer.periodic(
//       const Duration(seconds: 4),
//       (timer) {
//         if (!mounted) return;
//
//         final nextPage = (_page + 1) % _slides.length;
//
//         _controller.animateToPage(
//           nextPage,
//           duration: const Duration(milliseconds: 450),
//           curve: Curves.easeInOut,
//         );
//       },
//     );
//   }
//
//   void _onPageChanged(int index) {
//     setState(() => _page = index);
//
//     // Reset auto-scroll timer on manual swipe.
//     _startAutoScroll();
//   }
//
//   @override
//   void dispose() {
//     _autoScrollTimer?.cancel();
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: Container(
//             decoration: AppGloss.card(
//               r: AppGloss.radiusSm,
//               shadow: const [
//                 BoxShadow(
//                   color: Color(0x38000000),
//                   blurRadius: 24,
//                   offset: Offset(0, 12),
//                 ),
//               ],
//             ),
//             clipBehavior: Clip.antiAlias,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 PageView.builder(
//                   controller: _controller,
//                   itemCount: _slides.length,
//                   onPageChanged: _onPageChanged,
//                   itemBuilder: (context, index) => _SlideView(
//                     slide: _slides[index],
//                   ),
//                 ),
//
//                 // Top-left floating badge "Women in Action"
//                 Positioned(
//                   top: 12,
//                   left: 12,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withValues(alpha: 0.50),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: Colors.white.withValues(alpha: 0.35),
//                       ),
//                     ),
//                     child: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.person_outline,
//                           color: Colors.white,
//                           size: 15,
//                         ),
//                         SizedBox(width: 6),
//                         Text(
//                           'Women in Action',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             for (var i = 0; i < _slides.length; i++)
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 margin: const EdgeInsets.symmetric(horizontal: 3),
//                 height: 5,
//                 width: i == _page ? 16 : 5,
//                 decoration: BoxDecoration(
//                   color: i == _page
//                       ? AppColors.primary
//                       : AppColors.primary.withValues(alpha: 0.35),
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// class _SlideView extends StatelessWidget {
//   final _Slide slide;
//
//   const _SlideView({required this.slide});
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         Container(
//           color: const Color(0xFF1F081D),
//           child: Image.asset(
//             slide.image,
//             fit: BoxFit.cover,
//             alignment: Alignment.center,
//             errorBuilder: (_, __, ___) => Container(
//               color: Colors.grey.shade800,
//               child: const Center(
//                 child: Icon(
//                   Icons.image,
//                   size: 36,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),
//           ),
//         ),
//
//         // Gradient overlay for text legibility
//         Positioned.fill(
//           child: DecoratedBox(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.transparent,
//                   Colors.black.withValues(alpha: 0.20),
//                   Colors.black.withValues(alpha: 0.85),
//                 ],
//                 stops: const [0.0, 0.45, 1.0],
//               ),
//             ),
//           ),
//         ),
//
//         Positioned(
//           left: 14,
//           right: 14,
//           bottom: 12,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 slide.title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   shadows: [
//                     Shadow(
//                       color: Colors.black54,
//                       blurRadius: 4,
//                       offset: Offset(0, 1),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 slide.subtitle,
//                 style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
