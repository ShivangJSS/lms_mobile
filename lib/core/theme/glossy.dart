import 'package:flutter/material.dart';

import 'colors.dart';

/// Shared "glossy finish" surface, shadow and highlight recipes.
///
/// Every screen reaches for the same handful of decorations here instead of
/// hand-rolling shadows and gradients, so the whole app catches light the same
/// way: soft brand-tinted shadows, a faint diagonal sheen on light cards,
/// frosted panels over the brand gradient, and top-lit glossy buttons.
///
/// Usage:
/// ```dart
/// Container(decoration: AppGloss.card(), child: ...);          // white card
/// Container(decoration: AppGloss.glass(), child: ...);         // on gradient
/// Container(decoration: AppGloss.header(), child: ...);        // hero header
/// ```
class AppGloss {
  AppGloss._();

  // Corner radii tuned for a soft, modern feel.
  static const double radius = 18;
  static const double radiusLg = 24;
  static const double radiusSm = 12;

  /// Resting elevation for cards and tiles.
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0F702068), blurRadius: 3, offset: Offset(0, 1)),
  ];

  /// Stronger lift for hero cards, sheets and floating actions.
  static const List<BoxShadow> lifted = [
    BoxShadow(color: Color(0x1F4A1444), blurRadius: 28, offset: Offset(0, 14)),
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// Coloured glow under a glossy primary button — layered for a raised,
  /// 3D-button feel (deep brand glow plus a tight contact shadow).
  static const List<BoxShadow> buttonGlow = [
    BoxShadow(color: Color(0x55702068), blurRadius: 24, offset: Offset(0, 14)),
    BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3)),
  ];

  /// Glossy white card: faint diagonal sheen, hairline edge, soft shadow.
  static BoxDecoration card({double r = radius, List<BoxShadow>? shadow}) {
    return BoxDecoration(
      gradient: AppColors.cardSheen,
      borderRadius: BorderRadius.circular(r),
      border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
      boxShadow: shadow ?? soft,
    );
  }

  /// Flat tinted panel (option tiles, muted sections) with a hairline edge.
  static BoxDecoration panel({Color? color, double r = radius}) {
    return BoxDecoration(
      color: color ?? AppColors.tintedPanel,
      borderRadius: BorderRadius.circular(r),
      border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
    );
  }

  /// Frosted translucent panel for use ON TOP of the brand gradient — pairs
  /// well with a [BackdropFilter] but reads as glass on its own too.
  static BoxDecoration glass({double r = radius, double opacity = 0.16}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(r),
      border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
    );
  }

  /// Glossy gradient surface for primary buttons. Pair with [sheen] on top for
  /// the wet-glass highlight.
  static BoxDecoration button({double r = radiusSm, bool enabled = true}) {
    return BoxDecoration(
      gradient: enabled ? AppColors.buttonGloss : AppColors.buttonGlossDisabled,
      borderRadius: BorderRadius.circular(r),
      boxShadow: enabled ? buttonGlow : null,
    );
  }

  /// Rich brand header/hero gradient with a rounded bottom and soft drop.
  static BoxDecoration header({double r = 34, bool shadow = true}) {
    return BoxDecoration(
      gradient: AppColors.brandGradientRich,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(r),
        bottomRight: Radius.circular(r),
      ),
      boxShadow: shadow
          ? const [
              BoxShadow(
                color: Color(0x33702068),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ]
          : null,
    );
  }

  /// A thin top highlight to lay over any glossy surface (button/header) for
  /// the "wet" sheen. Add as the first child of a [Stack] that fills the
  /// surface; it is ignored by pointers.
  static Widget sheen({double r = radiusSm}) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            heightFactor: 0.5,
            widthFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(r)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
