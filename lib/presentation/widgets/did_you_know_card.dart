import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/media_url.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/glossy.dart';
import '../../domain/entities/dashboard_tip.dart';

/// Road-safety tip card on the dashboard, fed by the didyouknow table.
class DidYouKnowCard extends StatelessWidget {
  final DashboardTip tip;
  final int languageId;

  const DidYouKnowCard({
    super.key,
    required this.tip,
    required this.languageId,
  });

  @override
  Widget build(BuildContext context) {
    final image = mediaUrl(tip.imageUrl, folder: 'didyouknow');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Warm glossy tint so the tip keeps its amber identity but catches
        // light like the rest of the glossy surfaces.
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDF6), Color(0xFFFFF3D6)],
        ),
        borderRadius: BorderRadius.circular(AppGloss.radius),
        border: Border.all(color: const Color(0xFFFCE4A6)),
        boxShadow: AppGloss.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(AppGloss.radiusSm),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF9A825).withValues(alpha: 0.20),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Color(0xFFF9A825),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.of('did_you_know', languageId),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppGloss.radiusSm),
              child: Image.network(
                image,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                // The legacy tip images are not on this server, so a missing
                // file falls back to text only rather than a broken box.
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          if (image != null) const SizedBox(height: 12),
          Text(
            tip.text,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }
}
