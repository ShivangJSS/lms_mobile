import 'package:flutter/material.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../domain/entities/module_assessment.dart';

/// The muted purple bar at the top of every assessment page.
///
/// MCQ and SCQ name their type; drop bucket and match making just read
/// "Assessment", matching the reference screens.
class AssessmentHeader extends StatelessWidget {
  final String title;

  const AssessmentHeader({super.key, required this.title});

  factory AssessmentHeader.forQuestion(AssessmentQuestionItem question) {
    final suffix = switch (question.type) {
      QuestionType.mcq => ' (MCQ)',
      QuestionType.scq => ' (SCQ)',
      _ => '',
    };

    return AssessmentHeader(title: 'Assessment$suffix');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientRich,
        borderRadius: BorderRadius.circular(AppGloss.radius),
        boxShadow: AppGloss.soft,
      ),
      child: Stack(
        children: [
          AppGloss.sheen(r: AppGloss.radius),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: AppText.sectionTitle,
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

/// Teal Previous / Next / Submit bar pinned to the bottom.
class AssessmentNavBar extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool isBusy;

  const AssessmentNavBar({
    super.key,
    required this.nextLabel,
    this.onPrevious,
    this.onNext,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final next = PrimaryButton(
      text: nextLabel,
      isLoading: isBusy,
      onPressed: onNext,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
        child: onPrevious == null
            ? SizedBox(width: double.infinity, child: next)
            : Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: AppButton.height,
                      child: DecoratedBox(
                        decoration: AppGloss.panel(
                          color: AppColors.tintedPanel,
                          r: AppGloss.radiusSm,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppGloss.radiusSm),
                          child: InkWell(
                            onTap: isBusy ? null : onPrevious,
                            borderRadius:
                                BorderRadius.circular(AppGloss.radiusSm),
                            child: const Center(
                              child: Text(
                                'Previous',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: next),
                ],
              ),
      ),
    );
  }
}
