import 'package:flutter/material.dart';

import '../../domain/entities/module_assessment.dart';

/// Result screen: an outcome card, the score as the focal point, the
/// question breakdown, then Retry or Continue.
///
/// The palette below is this screen's own. It is deliberately cooler and more
/// neutral than the app-wide brand purple — a result page reads better when the
/// only saturated colour on it is the score itself.
class _Palette {
  _Palette._();

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleDeep = Color(0xFF5B21B6);
  static const Color green = Color(0xFF16A34A);
  static const Color amber = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);

  static const Color ink = Color(0xFF1F2937);
  static const Color inkSoft = Color(0xFF6B7280);

  static const Color page = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color hairline = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Icon wells, one per statistic.
  static const Color wellPurple = Color(0xFFEEE5FF);
  static const Color wellGreen = Color(0xFFDCFCE7);
  static const Color wellAmber = Color(0xFFFEF3C7);
  static const Color wellRed = Color(0xFFFEE2E2);

  // Outcome washes.
  static const Color washFail = Color(0xFFFEECEC);
  static const Color washPass = wellGreen;
  static const Color scoreFail = Color(0xFFFFF5F5);
  static const Color scorePass = Color(0xFFF0FDF4);

  /// Card elevation: blur 20, 8% black, dropped 8.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
}

const double _gap = 24;

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

    return ColoredBox(
      color: _Palette.page,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(_gap, _gap, _gap, _gap / 2),
              child: Column(
                children: [
                  _OutcomeCard(result: result),
                  const SizedBox(height: _gap),
                  _ScoreCard(result: result),
                  const SizedBox(height: _gap),
                  _StatsCard(result: result),
                  if (passed && result.nextModuleName != null) ...[
                    const SizedBox(height: _gap),
                    _UnlockedBanner(moduleName: result.nextModuleName!),
                  ],
                ],
              ),
            ),
          ),
          // Retry is always offered: a participant may reattempt the
          // assessment whether they passed or failed.
          _Actions(
            passed: passed,
            onRetry: onRetry,
            onDone: onDone,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Outcome
// -----------------------------------------------------------------------------

class _OutcomeCard extends StatelessWidget {
  final AssessmentResult result;

  const _OutcomeCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final passed = result.passed;
    final pass = result.passPercentage.round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_gap),
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _Palette.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: passed ? _Palette.washPass : _Palette.washFail,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Image.asset(
                passed
                    ? 'assets/images/pass_assessment.png'
                    : 'assets/images/fail_assessment.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  passed ? Icons.thumb_up_rounded : Icons.thumb_down_rounded,
                  size: 34,
                  color: passed ? _Palette.green : _Palette.red,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            passed ? 'Well Done!' : 'Keep Trying!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _Palette.ink,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            passed
                ? 'You scored $pass% or above. The next module is now open.'
                : 'You scored below $pass%. Review the module and strengthen '
                    'your understanding before attempting the assessment again.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: _Palette.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Score
// -----------------------------------------------------------------------------

/// The focal point of the page: the percentage, and nothing competing with it.
class _ScoreCard extends StatelessWidget {
  final AssessmentResult result;

  const _ScoreCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final passed = result.passed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_gap),
      decoration: BoxDecoration(
        color: passed ? _Palette.scorePass : _Palette.scoreFail,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Your Score',
            style: TextStyle(fontSize: 16, color: _Palette.inkSoft),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${result.scorePercentage.toStringAsFixed(1)}%',
              maxLines: 1,
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                height: 1.15,
                color: passed ? _Palette.green : _Palette.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Statistics
// -----------------------------------------------------------------------------

class _StatsCard extends StatelessWidget {
  final AssessmentResult result;

  const _StatsCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      _StatRow(
        icon: Icons.description_outlined,
        well: _Palette.wellPurple,
        iconColor: _Palette.purple,
        label: 'Total Questions',
        value: '${result.totalQuestions}',
        valueColor: _Palette.ink,
      ),
      _StatRow(
        icon: Icons.check_circle,
        well: _Palette.wellGreen,
        iconColor: _Palette.green,
        label: 'Correct',
        value: '${result.correctAnswers}',
        valueColor: _Palette.green,
      ),
      // Kept on show at zero: it explains why a half-right multi-select did
      // not count as correct, which is only reassuring if the row is always
      // there to be read.
      _StatRow(
        icon: Icons.contrast,
        well: _Palette.wellAmber,
        iconColor: _Palette.amber,
        label: 'Partly Right',
        value: '${result.partiallyCorrect}',
        valueColor: _Palette.amber,
      ),
      _StatRow(
        icon: Icons.cancel,
        well: _Palette.wellRed,
        iconColor: _Palette.red,
        label: 'Wrong',
        value: '${result.wrongAnswers}',
        valueColor: _Palette.red,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Palette.hairline),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: _Palette.divider),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color well;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _StatRow({
    required this.icon,
    required this.well,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(color: well, shape: BoxShape.circle),
              child: Icon(icon, size: 21, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, color: _Palette.ink),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown only when a pass has opened the next module.
class _UnlockedBanner extends StatelessWidget {
  final String moduleName;

  const _UnlockedBanner({required this.moduleName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Palette.scorePass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Palette.wellGreen),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              color: _Palette.wellGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_open_rounded,
              size: 21,
              color: _Palette.green,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Unlocked: $moduleName',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _Palette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Actions
// -----------------------------------------------------------------------------

/// Which callback sits on which button is unchanged: a pass leads with
/// Continue and offers a retry underneath, a fail leads with Try Again.
class _Actions extends StatelessWidget {
  final bool passed;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  const _Actions({
    required this.passed,
    required this.onRetry,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_gap, _gap / 2, _gap, _gap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PrimaryAction(
              label: passed ? 'Continue' : 'Try Again',
              icon: passed
                  ? Icons.arrow_forward_rounded
                  : Icons.refresh_rounded,
              onPressed: passed ? onDone : onRetry,
            ),
            const SizedBox(height: 16),
            _SecondaryAction(
              label: passed ? 'Try Again' : 'Back to Module',
              icon: passed
                  ? Icons.refresh_rounded
                  : Icons.menu_book_outlined,
              onPressed: passed ? onRetry : onDone,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_Palette.purple, _Palette.purpleDeep],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D7C3AED),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 21, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SecondaryAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _Palette.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _Palette.purple, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 21, color: _Palette.purple),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _Palette.purple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
