import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/glossy.dart';

class DashboardStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;

  /// Optional glossy icon badge shown above the value.
  final IconData? icon;

  const DashboardStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10.0),
        decoration: BoxDecoration(
          // A subtle brand-tinted gradient over the base colour makes the tile
          // read as a lit piece of glass rather than a flat swatch.
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.85),
              backgroundColor,
            ],
          ),
          borderRadius: BorderRadius.circular(AppGloss.radius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          boxShadow: AppGloss.soft,
        ),
        child: Column(
          children: [
            if (icon != null) ...[
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(AppGloss.radiusSm),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
