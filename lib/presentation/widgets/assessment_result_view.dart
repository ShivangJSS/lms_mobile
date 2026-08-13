import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../domain/entities/module_assessment.dart';

/// Result screen: a coloured banner, then the Total / Correct / Wrong /
/// Score breakdown, then Retry or Continue.
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
    final accent = passed ? AppColors.resultPass : AppColors.resultFail;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              Image.asset(
                passed
                    ? 'assets/images/pass_assessment.png'
                    : 'assets/images/fail_assessment.png',
                height: 150,
                errorBuilder: (_, __, ___) => Icon(
                  passed ? Icons.thumb_up : Icons.thumb_down,
                  size: 110,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                passed ? 'Well Done!' : 'Keep Trying!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                passed
                    ? 'You scored ${result.passPercentage.round()}% or above. '
                        'The next module is now open.'
                    : 'You scored below ${result.passPercentage.round()}%. We '
                        'recommend revisiting the module to strengthen your '
                        'understanding before attempting the assessment again.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            child: Column(
              children: [
                _Row(label: 'Total', value: '${result.totalQuestions}'),
                _Row(
                  label: 'Correct',
                  value: '${result.correctAnswers}',
                  color: AppColors.resultPass,
                ),
                _Row(
                  label: 'Wrong',
                  value: '${result.wrongAnswers}',
                  color: AppColors.resultFail,
                ),
                // Explains why a half-right multi-select still counts as a
                // miss, rather than leaving the number unexplained.
                if (result.partiallyCorrect > 0)
                  _Row(
                    label: 'Partly right',
                    value: '${result.partiallyCorrect}',
                    color: Colors.orange.shade800,
                  ),
                _Row(
                  label: 'Score',
                  value: '${result.scorePercentage.toStringAsFixed(1)}%',
                  color: accent,
                ),
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
                        const Icon(
                          Icons.lock_open,
                          color: AppColors.resultPass,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Unlocked: ${result.nextModuleName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            // Retry is always offered: a participant may reattempt the
            // assessment whether they passed or failed.
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: passed ? onDone : onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      passed ? 'Continue' : 'Try Again',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: passed ? onRetry : onDone,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      passed ? 'Try Again' : 'Back to module',
                      style: TextStyle(
                        color: accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Row({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 20),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
