import 'package:flutter/material.dart';

import '../../../core/network/media_url.dart';

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
        Text(
          'Q$number : $title',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(
            hint!,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
        if (image != null) ...[
          const SizedBox(height: 18),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                image,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
        const SizedBox(height: 22),
      ],
    );
  }
}
