import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/entities/learning_module.dart';
import '../../viewmodels/language_view_model.dart';
import '../../viewmodels/module_topics_view_model.dart';
import '../../widgets/module_overview_card.dart';
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
    final lang = ref.watch(languageProvider).languageId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Women With Wheels'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && state.topics.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return _Message(
              text: state.error!,
              languageId: lang,
              onRetry: viewModel.load,
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: viewModel.load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    children: [
                      if (state.overview != null)
                        ModuleOverviewCard(
                          overview: state.overview!,
                          languageId: lang,
                        )
                      else
                        SectionBanner(title: moduleName),
                      const SizedBox(height: 22),
                      SectionBanner(
                        title: AppStrings.of('topics', lang),
                      ),
                      const SizedBox(height: 10),
                      if (state.topics.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 28),
                          child: Center(
                            child: Text(
                              'No topics have been published yet.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        for (var i = 0; i < state.topics.length; i++) ...[
                          TopicCard(
                            topic: state.topics[i],
                            index: i,
                            onTap: () => _showTopic(context, state.topics[i]),
                          ),
                          if (i != state.topics.length - 1)
                            const Divider(height: 1),
                        ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              _PostAssessmentBar(
                moduleId: moduleId,
                moduleName: state.overview?.moduleName ?? moduleName,
              ),
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
            Row(
              children: [
                TopicTypeIcon(topic: topic, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    topic.topicName ?? 'Untitled topic',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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

/// Teal Post Assessment button pinned under the topic list. Completing it is
/// what finishes the module and opens the next one.
class _PostAssessmentBar extends ConsumerWidget {
  final int moduleId;
  final String moduleName;

  const _PostAssessmentBar({
    required this.moduleId,
    required this.moduleName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.push(
              AppRoutes.moduleAssessmentPath(moduleId),
              extra: moduleName,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.assessmentAction,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Post Assessment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
  final int languageId;
  final Future<void> Function() onRetry;

  const _Message({
    required this.text,
    required this.languageId,
    required this.onRetry,
  });

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
            TextButton(
              onPressed: onRetry,
              child: Text(AppStrings.of('retry', languageId)),
            ),
          ],
        ),
      ),
    );
  }
}
