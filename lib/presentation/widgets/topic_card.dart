import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/colors.dart';
import '../../domain/entities/learning_module.dart';

/// A topic row: type icon, title, chevron. Matches the reference list where
/// each topic is a plain row rather than a boxed card.
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
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
            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

/// Play circle for video, PDF and PPT badges for documents.
class TopicTypeIcon extends StatelessWidget {
  final ModuleTopic topic;
  final double size;

  const TopicTypeIcon({super.key, required this.topic, this.size = 32});

  @override
  Widget build(BuildContext context) {
    if (topic.isVideo) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: size * 0.6,
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
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
