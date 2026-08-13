import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../domain/entities/learning_module.dart';

/// Row in the module detail list: one topic and the document attached to it.
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _TypeBadge(topic: topic),
        title: Text(
          topic.topicName ?? 'Untitled topic',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            _subtitle,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        trailing: Icon(
          topic.hasContent ? Icons.chevron_right : Icons.hourglass_empty,
          color: topic.hasContent ? AppColors.primary : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  String get _subtitle {
    final parts = <String>[
      '${index + 1}',
      if (topic.docType != null) topic.docType!,
      if (topic.durationMinutes != null) '${topic.durationMinutes} min',
    ];

    return parts.join('  •  ');
  }
}

class _TypeBadge extends StatelessWidget {
  final ModuleTopic topic;

  const _TypeBadge({required this.topic});

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color color;
    late final Color background;

    if (topic.isVideo) {
      icon = Icons.play_circle_fill;
      color = const Color(0xFFD32F2F);
      background = const Color(0xFFFFEBEE);
    } else if (topic.isPdf) {
      icon = Icons.picture_as_pdf;
      color = const Color(0xFFE64A19);
      background = const Color(0xFFFBE9E7);
    } else if (topic.isPpt) {
      icon = Icons.slideshow;
      color = const Color(0xFFF57C00);
      background = const Color(0xFFFFF3E0);
    } else {
      icon = Icons.article;
      color = AppColors.primary;
      background = const Color(0xFFF3E5F5);
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, color: color),
    );
  }
}
