import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';
import '../../../domain/entities/learning_module.dart';
import '../../viewmodels/language_view_model.dart';
import '../../viewmodels/module_topics_view_model.dart';
import '../viewer/topic_viewer_screen.dart';
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Women With Wheels'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.brandGradientRich),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.pageWash),
        child: Builder(
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
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                    children: [
                      if (state.overview != null)
                        ModuleOverviewCard(
                          overview: state.overview!,
                          languageId: lang,
                        )
                      else
                        SectionBanner(title: moduleName),
                      const SizedBox(height: AppSpacing.lg),
                      SectionBanner(
                        title: AppStrings.of('topics', lang),
                      ),
                      const SizedBox(height: AppSpacing.sm),
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
                        for (var i = 0; i < state.topics.length; i++)
                          TopicCard(
                            topic: state.topics[i],
                            index: i,
                            onTap: () => _openTopic(context, state.topics[i]),
                          ),
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
      ),
    );
  }

  /// Opens the document itself rather than describing where it lives.
  void _openTopic(BuildContext context, ModuleTopic topic) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TopicViewerScreen(topic: topic),
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppGloss.radiusSm),
            boxShadow: [
              BoxShadow(
                color: AppColors.assessmentAction.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppGloss.radiusSm),
            child: InkWell(
              onTap: () => context.push(
                AppRoutes.moduleAssessmentPath(moduleId),
                extra: moduleName,
              ),
              borderRadius: BorderRadius.circular(AppGloss.radiusSm),
              child: Container(
                height: AppButton.height,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF12B981), AppColors.assessmentAction],
                  ),
                  borderRadius: BorderRadius.circular(AppGloss.radiusSm),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AppGloss.sheen(r: AppGloss.radiusSm),
                    const Text('Post Assessment', style: AppText.button),
                  ],
                ),
              ),
            ),
          ),
        ),
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
