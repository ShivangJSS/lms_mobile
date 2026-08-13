import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/entities/learning_module.dart';
import '../../viewmodels/language_view_model.dart';
import '../../viewmodels/module_topics_view_model.dart';
import '../../widgets/topic_card.dart';

class ModuleDetailScreen extends ConsumerWidget {
  final int moduleId;
  final String moduleName;

  const ModuleDetailScreen({
    super.key,
    required this.moduleId,
    required this.moduleName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moduleTopicsViewModelProvider(moduleId));
    final viewModel =
        ref.read(moduleTopicsViewModelProvider(moduleId).notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(moduleName.isEmpty ? 'Module' : moduleName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && state.topics.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return _Message(text: state.error!, onRetry: viewModel.load);
          }

          if (state.topics.isEmpty) {
            return _Message(
              text: 'No topics have been published for this module yet.',
              onRetry: viewModel.load,
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: viewModel.load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.topics.length,
                    itemBuilder: (context, index) {
                      final topic = state.topics[index];

                      return TopicCard(
                        topic: topic,
                        index: index,
                        onTap: () => _showTopic(context, topic),
                      );
                    },
                  ),
                ),
              ),
              _AssessmentBar(moduleId: moduleId, moduleName: moduleName),
            ],
          );
        },
      ),
    );
  }

  void _showTopic(BuildContext context, ModuleTopic topic) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic.topicName ?? 'Untitled topic',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (topic.docTitle != null)
              _Row(label: 'Document', value: topic.docTitle!),
            if (topic.docType != null)
              _Row(label: 'Type', value: topic.docType!),
            if (topic.durationMinutes != null)
              _Row(label: 'Duration', value: '${topic.durationMinutes} min'),
            _Row(
              label: 'File',
              value: topic.youtubeUrl?.isNotEmpty == true
                  ? topic.youtubeUrl!
                  : (topic.contentPath ?? 'Not uploaded yet'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sits under the topic list: the participant works through the content and
/// then takes the MCQ, which is what completes the module.
class _AssessmentBar extends ConsumerWidget {
  final int moduleId;
  final String moduleName;

  const _AssessmentBar({required this.moduleId, required this.moduleName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider).languageId;

    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.of('unlock_note', lang),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => context.push(
                AppRoutes.moduleAssessmentPath(moduleId),
                extra: moduleName,
              ),
              icon: const Icon(Icons.quiz, color: Colors.white),
              label: Text(
                AppStrings.of('start_assessment', lang),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final Future<void> Function() onRetry;

  const _Message({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
