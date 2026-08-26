import 'package:flutter/material.dart';

import '../theme/app_text.dart';
import '../theme/glossy.dart';

/// The app's primary action button, with a glossy top-lit gradient, a wet
/// sheen highlight and a soft coloured glow. One height for the whole app
/// (see [AppButton.height]).
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Optional trailing icon (e.g. an arrow on "Login" / "Next").
  final IconData? trailingIcon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return Semantics(
      button: true,
      enabled: enabled,
      label: text,
      child: DecoratedBox(
        decoration: AppGloss.button(enabled: enabled),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppGloss.radiusSm),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AppGloss.radiusSm),
            child: Container(
              width: double.infinity,
              height: AppButton.height,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AppGloss.sheen(),
                  if (isLoading)
                    const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                              text,
                              style: AppText.button,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) ...[
                          const SizedBox(width: 8),
                          Icon(trailingIcon, color: Colors.white, size: 20),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
