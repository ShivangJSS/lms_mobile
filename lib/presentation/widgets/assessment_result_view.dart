import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/colors.dart';
import '../../domain/entities/module_assessment.dart';

/// Shown after an attempt: the score, whether the module completed, and
/// which module it unlocked.
class AssessmentResultView extends StatelessWidget {
  final AssessmentResult result;
  final int languageId;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  const AssessmentResultView({
    super.key,
    required this.result,
    required this.languageId,
    required this.onRetry,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final passed = result.passed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Image.asset(
            passed
                ? 'assets/images/pass_assessment.png'
                : 'assets/images/fail_assessment.png',
            height: 160,
            errorBuilder: (_, __, ___) => Icon(
              passed ? Icons.check_circle : Icons.replay_circle_filled,
              size: 120,
              color: passed ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${result.scorePercentage.round()}%',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: passed ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${result.correctAnswers} / ${result.totalQuestions} correct',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Text(
            passed
                ? AppStrings.of('module_completed_msg', languageId)
                : AppStrings.of('try_again_msg', languageId),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          if (!passed) ...[
            const SizedBox(height: 8),
            Text(
              'You need ${result.passPercentage.round()}% to pass.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
          if (passed && result.nextModuleName != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_open, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Unlocked: ${result.nextModuleName}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          if (!passed)
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(AppStrings.of('retry', languageId)),
            ),
          if (!passed) const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text(
              'Back to module',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
