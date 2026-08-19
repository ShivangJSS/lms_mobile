import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/glossy.dart';
import '../../domain/entities/learning_module.dart';

/// A topic row rendered as a glossy card: type badge, title, chevron.
class TopicCard extends StatelessWidget {
  final ModuleTopic topic;
  final int index;
  final VoidCallback? onTap;

  const TopicCard({
    super.key,
    required this.topic,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: AppGloss.card(r: AppGloss.radius),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppGloss.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppGloss.radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.md,
            ),
            child: Row(
              children: [
                TopicTypeIcon(topic: topic),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    topic.topicName ?? 'Untitled topic',
                    style: AppText.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Play circle for video, PDF and PPT badges for documents.
class TopicTypeIcon extends StatelessWidget {
  final ModuleTopic topic;
  final double size;

  const TopicTypeIcon({super.key, required this.topic, this.size = 40});

  @override
  Widget build(BuildContext context) {
    if (topic.isVideo) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradientRich,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: AppGloss.soft,
        ),
        child: Stack(
          children: [
            _CircleSheen(size: size),
            Center(
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: size * 0.6,
              ),
            ),
          ],
        ),
      );
    }

    // A topic with no doc_type is not a presentation — it gets its own
    // neutral badge rather than being mislabelled PPT.
    final label = topic.isPdf
        ? 'PDF'
        : topic.isPpt
            ? 'PPT'
            : 'DOC';

    final colour = topic.isPdf
        ? const Color(0xFFE53935)
        : topic.isPpt
            ? const Color(0xFFE64A19)
            : AppColors.primaryLight;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(AppGloss.radiusSm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: AppGloss.soft,
      ),
      alignment: Alignment.center,
      child: Stack(
        children: [
          AppGloss.sheen(r: AppGloss.radiusSm),
          Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A soft top highlight clipped to a circular badge.
class _CircleSheen extends StatelessWidget {
  final double size;

  const _CircleSheen({required this.size});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            heightFactor: 0.5,
            widthFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(size),
                ),
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
