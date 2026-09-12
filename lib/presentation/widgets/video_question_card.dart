import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/glossy.dart';
import '../../domain/entities/video_question.dart';

/// One post-video question with its options. When [revealed] is true the
/// options are locked and coloured by correctness.
class VideoQuestionCard extends StatelessWidget {
  final int index;
  final VideoQuizQuestion question;
  final Set<int> selected;
  final bool revealed;
  final void Function(int optionId) onTap;

  const VideoQuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.selected,
    required this.revealed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppGloss.card(r: AppGloss.radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$index. ${question.questionTitle ?? ''}', style: AppText.label),
          const SizedBox(height: AppSpacing.md),
          for (final option in question.options)
            _OptionRow(
              text: option.optionText ?? '',
              chosen: selected.contains(option.optionId),
              correct: revealed ? option.isCorrect : null,
              multi: question.allowsMultiple,
              onTap: () => onTap(option.optionId),
            ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String text;
  final bool chosen;
  final bool? correct;
  final bool multi;
  final VoidCallback onTap;

  const _OptionRow({
    required this.text,
    required this.chosen,
    required this.correct,
    required this.multi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color border = AppColors.hairline;
    Color fill = AppColors.surface;

    if (correct == true) {
      border = AppColors.success;
      fill = AppColors.success.withValues(alpha: 0.10);
    } else if (correct == false && chosen) {
      border = AppColors.error;
      fill = AppColors.error.withValues(alpha: 0.10);
    } else if (chosen) {
      border = AppColors.primary;
      fill = AppColors.primary.withValues(alpha: 0.06);
    }

    IconData icon;
    if (multi) {
      icon = chosen ? Icons.check_box : Icons.check_box_outline_blank;
    } else {
      icon = chosen ? Icons.radio_button_checked : Icons.radio_button_unchecked;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(AppGloss.radiusSm),
        child: InkWell(
          onTap: correct == null ? onTap : null,
          borderRadius: BorderRadius.circular(AppGloss.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppGloss.radiusSm),
              border: Border.all(color: border, width: 1.4),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: chosen ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(text, style: AppText.body)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
