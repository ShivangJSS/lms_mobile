import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            TopicTypeIcon(topic: topic),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                topic.topicName ?? 'Untitled topic',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
              size: 28,
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

  const TopicTypeIcon({super.key, required this.topic, this.size = 40});

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

    final isPdf = topic.isPdf;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isPdf ? const Color(0xFFE53935) : const Color(0xFFE64A19),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        isPdf ? 'PDF' : 'PPT',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
