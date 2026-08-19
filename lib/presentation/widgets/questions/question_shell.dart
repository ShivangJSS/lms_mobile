import 'package:flutter/material.dart';

import '../../../core/network/media_url.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';
import '../../../domain/entities/module_assessment.dart';

/// Shared frame around every question: number, title, hint and image.
class QuestionShell extends StatelessWidget {
  final AssessmentQuestionItem question;
  final int index;
  final String? hint;
  final Widget child;

  const QuestionShell({
    super.key,
    required this.question,
    required this.index,
    required this.child,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final image = mediaUrl(question.imageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: AppGloss.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 28,
                width: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: AppColors.buttonGloss,
                  shape: BoxShape.circle,
                  boxShadow: AppGloss.buttonGlow,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question.questionTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (hint != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: Text(
                hint!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          if (image != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
