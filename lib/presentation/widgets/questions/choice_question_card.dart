import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';
import '../../../domain/entities/module_assessment.dart';
import '../../viewmodels/module_assessment_view_model.dart';
import 'question_prompt.dart';

/// MCQ and SCQ. Options are full-width tappable pills rather than radios or
/// checkboxes, matching the reference screens.
class ChoiceQuestionCard extends ConsumerWidget {
  final AssessmentQuestionItem question;
  final int number;
  final int moduleId;
  final int languageId;

  const ChoiceQuestionCard({
    super.key,
    required this.question,
    required this.number,
    required this.moduleId,
    required this.languageId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = moduleAssessmentViewModelProvider(moduleId);
    final viewModel = ref.read(provider.notifier);

    ref.watch(provider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppGloss.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionPrompt(
            number: number,
            title: question.questionTitle,
            imageUrl: question.imageUrl,
            hint: question.allowsMultiple
                ? AppStrings.of('select_all_apply', languageId)
                : null,
          ),
          for (final option in question.options)
            _OptionTile(
              text: option.optionText,
              selected: viewModel.isOptionSelected(question, option.optionId),
              onTap: () => viewModel.selectOption(question, option.optionId),
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: selected
            ? BoxDecoration(
                gradient: AppColors.buttonGloss,
                borderRadius: BorderRadius.circular(AppGloss.radiusSm),
                boxShadow: AppGloss.buttonGlow,
              )
            : AppGloss.panel(
                color: AppColors.optionTile,
                r: AppGloss.radiusSm,
              ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppGloss.radiusSm),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppGloss.radiusSm),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 46),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              alignment: Alignment.center,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: AppText.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.textWhite : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
