import 'package:flutter/material.dart';

import '../../../core/network/media_url.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/glossy.dart';

/// "Q3 : <title>" plus the question image, shared by all four types.
class QuestionPrompt extends StatelessWidget {
  final int number;
  final String title;
  final String? imageUrl;
  final String? hint;

  const QuestionPrompt({
    super.key,
    required this.number,
    required this.title,
    this.imageUrl,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final image = mediaUrl(imageUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Q$number : $title', style: AppText.h3),
        if (hint != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(hint!, style: AppText.caption),
        ],
        if (image != null) ...[
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: AppGloss.card(r: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  image,
                  height: 140,
                  width: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
