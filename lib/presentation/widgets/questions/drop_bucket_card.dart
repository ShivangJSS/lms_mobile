import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/media_url.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/entities/module_assessment.dart';
import '../../viewmodels/module_assessment_view_model.dart';
import 'question_prompt.dart';

/// "Items to sort" grid above two bucket graphics. Items are dragged into a
/// bucket; Reset empties them all again.
class DropBucketCard extends ConsumerWidget {
  final AssessmentQuestionItem question;
  final int number;
  final int moduleId;
  final int languageId;

  const DropBucketCard({
    super.key,
    required this.question,
    required this.number,
    required this.moduleId,
    required this.languageId,
  });

  static const _bucketArt = [
    'assets/images/bucket_yellow.png',
    'assets/images/bucket_green.png',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = moduleAssessmentViewModelProvider(moduleId);
    final viewModel = ref.read(provider.notifier);

    ref.watch(provider);

    final unplaced = question.items
        .where((item) => viewModel.bucketOf(question, item.itemId) == null)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionPrompt(
          number: number,
          title: question.questionTitle,
          imageUrl: question.imageUrl,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Items to sort:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => viewModel.resetPlacements(question),
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 8),
        if (unplaced.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'All items sorted',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 16,
            runSpacing: 18,
            children: [
              for (final item in unplaced) _ItemTile(item: item),
            ],
          ),
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < question.buckets.length; i++)
              Expanded(
                child: _BucketArt(
                  bucket: question.buckets[i],
                  art: _bucketArt[i % _bucketArt.length],
                  question: question,
                  moduleId: moduleId,
                  placed: question.items
                      .where(
                        (item) =>
                            viewModel.bucketOf(question, item.itemId) ==
                            question.buckets[i].bucketId,
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  final DraggableItem item;

  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final tile = _ItemVisual(item: item);

    return SizedBox(
      width: 96,
      child: Draggable<int>(
        data: item.itemId,
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(width: 96, child: _ItemVisual(item: item)),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: tile),
        child: tile,
      ),
    );
  }
}

class _ItemVisual extends StatelessWidget {
  final DraggableItem item;

  const _ItemVisual({required this.item});

  @override
  Widget build(BuildContext context) {
    final image = mediaUrl(item.image, folder: 'drop_bucket');

    return Column(
      children: [
        Container(
          height: 66,
          width: 96,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: image == null
              ? const Icon(Icons.image, color: Colors.grey)
              : Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image,
                    color: Colors.grey,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          item.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BucketArt extends ConsumerWidget {
  final Bucket bucket;
  final String art;
  final AssessmentQuestionItem question;
  final int moduleId;
  final List<DraggableItem> placed;

  const _BucketArt({
    required this.bucket,
    required this.art,
    required this.question,
    required this.moduleId,
    required this.placed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(
      moduleAssessmentViewModelProvider(moduleId).notifier,
    );

    return DragTarget<int>(
      onAcceptWithDetails: (details) => viewModel.placeItem(
        question,
        details.data,
        bucket.bucketId,
      ),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;

        return Column(
          children: [
            Transform.scale(
              scale: active ? 1.06 : 1.0,
              child: SizedBox(
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      art,
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    // Placed items sit inside the bucket; tap one to take it
                    // back out.
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 2,
                        runSpacing: 2,
                        children: [
                          for (final item in placed)
                            GestureDetector(
                              onTap: () => viewModel.removeItem(
                                question,
                                item.itemId,
                              ),
                              child: _PlacedChip(item: item),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              bucket.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlacedChip extends StatelessWidget {
  final DraggableItem item;

  const _PlacedChip({required this.item});

  @override
  Widget build(BuildContext context) {
    final image = mediaUrl(item.image, folder: 'drop_bucket');

    return Container(
      height: 26,
      width: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.black26),
      ),
      clipBehavior: Clip.antiAlias,
      child: image == null
          ? Center(
              child: Text(
                item.name.characters.take(3).toString(),
                style: const TextStyle(fontSize: 8),
              ),
            )
          : Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 12),
            ),
    );
  }
}
