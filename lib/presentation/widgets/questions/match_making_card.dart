import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';
import '../../../domain/entities/module_assessment.dart';
import '../../viewmodels/module_assessment_view_model.dart';
import 'question_prompt.dart';

/// Column A / Column B table. A Column B entry is dragged onto the Column A
/// row it belongs with; tapping a matched row releases it again.
class MatchMakingCard extends ConsumerWidget {
  final AssessmentQuestionItem question;
  final int number;
  final int moduleId;
  final int languageId;

  const MatchMakingCard({
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

    // Right entries already used are shown in place and not offered again.
    final used = <int>{};

    for (final left in question.leftItems) {
      final match = viewModel.matchOf(question, left.itemId);
      if (match != null) used.add(match);
    }

    final pool = question.rightItems
        .where((right) => !used.contains(right.itemId))
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppGloss.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // No imageUrl: these types have their own visuals below, and the
          // question-level image on these records is a shared placeholder.
          QuestionPrompt(
            number: number,
            title: question.questionTitle,
          ),
          Container(
            decoration: AppGloss.panel(
              color: AppColors.tintedPanel,
              r: AppGloss.radiusSm,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Column A',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Column B',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < question.leftItems.length; i++)
            _MatchRow(
              index: i,
              left: question.leftItems[i],
              question: question,
              moduleId: moduleId,
              matched: _rightFor(
                question,
                viewModel.matchOf(question, question.leftItems[i].itemId),
              ),
            ),
          const SizedBox(height: 18),
          if (pool.isNotEmpty) ...[
            const Text(
              'Drag from here:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final right in pool) _RightChip(item: right),
              ],
            ),
            const SizedBox(height: 18),
          ],
          const Text(
            'Note: Match the following by dragging the correct options from '
            'Column B to Column A.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  MatchItem? _rightFor(AssessmentQuestionItem question, int? rightId) {
    if (rightId == null) return null;

    for (final right in question.rightItems) {
      if (right.itemId == rightId) return right;
    }

    return null;
  }
}

class _RightChip extends StatelessWidget {
  final MatchItem item;

  const _RightChip({required this.item});

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.optionTile,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(item.text)),
          const SizedBox(width: 6),
          const Icon(Icons.pan_tool_alt_outlined, size: 16),
        ],
      ),
    );

    return Draggable<int>(
      data: item.itemId,
      feedback: Material(color: Colors.transparent, child: chip),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      child: chip,
    );
  }
}

class _MatchRow extends ConsumerWidget {
  final int index;
  final MatchItem left;
  final AssessmentQuestionItem question;
  final int moduleId;
  final MatchItem? matched;

  const _MatchRow({
    required this.index,
    required this.left,
    required this.question,
    required this.moduleId,
    required this.matched,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(
      moduleAssessmentViewModelProvider(moduleId).notifier,
    );

    return DragTarget<int>(
      onAcceptWithDetails: (details) => viewModel.pair(
        question,
        left.itemId,
        details.data,
      ),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: active ? const Color(0xFFF3E9F6) : Colors.transparent,
            border: const Border(
              bottom: BorderSide(color: AppColors.primaryLight),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${index + 1}. ${left.text}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                child: matched == null
                    ? Text(
                        active ? 'Drop here' : '—',
                        style: TextStyle(color: Colors.grey.shade500),
                      )
                    : GestureDetector(
                        onTap: () => viewModel.unpair(question, left.itemId),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                matched!.text,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(Icons.close, size: 16),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
