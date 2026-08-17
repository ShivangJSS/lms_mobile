import 'package:flutter/material.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.sectionHeader,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Text(
        title,
        style: AppText.sectionTitle,
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
    final next = SizedBox(
      height: AppButton.height,
      child: ElevatedButton(
        onPressed: isBusy ? null : onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.assessmentAction,
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isBusy
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(nextLabel),
      ),
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
                      child: ElevatedButton(
                        onPressed: isBusy ? null : onPrevious,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.assessmentAction,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Previous'),
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
