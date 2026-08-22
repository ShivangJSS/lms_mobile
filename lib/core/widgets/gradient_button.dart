import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import '../theme/colors.dart';

/// The app's primary action: a full-width pill with the brand gradient, a soft
/// coloured glow, a wet sheen and a press animation.
///
/// Purely presentational — it owns no state beyond the press effect, so the
/// screen keeps control of what tapping it does.
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Trailing icon, drawn after the label.
  final IconData? trailingIcon;

  final double height;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.trailingIcon = Icons.arrow_forward,
    this.height = 56,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    // A pill: the radius always tracks the height so the ends stay round
    // whatever the screen has room for.
    final radius = widget.height / 2;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.text,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: enabled
                ? AppColors.buttonGloss
                : AppColors.buttonGlossDisabled,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: enabled
                ? const [
                    BoxShadow(
                      color: Color(0x4D7C3AED),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
            child: InkWell(
              onTap: enabled ? widget.onPressed : null,
              onHighlightChanged: (down) => setState(() => _pressed = down),
              borderRadius: BorderRadius.circular(radius),
              child: SizedBox(
                height: widget.height,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _Sheen(radius: radius),
                    if (widget.isLoading)
                      const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.text,
                                maxLines: 1,
                                style: AppTypography.button.copyWith(
                                  fontSize: widget.height * 0.36,
                                ),
                              ),
                            ),
                          ),
                          if (widget.trailingIcon != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              widget.trailingIcon,
                              color: AppColors.white,
                              size: widget.height * 0.36,
                            ),
                          ],
                        ],
                      ),
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

/// The thin top highlight that makes the gradient read as glass.
class _Sheen extends StatelessWidget {
  final double radius;

  const _Sheen({required this.radius});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            heightFactor: 0.5,
            widthFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(radius),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.26),
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
