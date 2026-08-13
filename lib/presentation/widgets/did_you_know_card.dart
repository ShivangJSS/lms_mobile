import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/media_url.dart';
import '../../core/theme/colors.dart';
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
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb,
                color: Color(0xFFF9A825),
              ),
              const SizedBox(width: 8),
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
              borderRadius: BorderRadius.circular(8),
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
