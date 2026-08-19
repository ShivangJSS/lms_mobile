import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/glossy.dart';

class ProgressCard extends StatelessWidget {
  final double progress;
  final String progressText;
  final String message;

  const ProgressCard({
    super.key,
    required this.progress,
    required this.progressText,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppGloss.card(r: AppGloss.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Glossy brand-gradient header band with a wet sheen highlight.
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradientRich,
                ),
                child: const Text(
                  'Your Progress',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AppGloss.sheen(r: 0),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 16,
                          backgroundColor: AppColors.tintedPanel,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.progressGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      progressText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
