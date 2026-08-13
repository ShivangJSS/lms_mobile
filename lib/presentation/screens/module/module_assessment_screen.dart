import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/media_url.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/entities/module_assessment.dart';
import '../../viewmodels/dashboard_view_model.dart';
import '../../viewmodels/language_view_model.dart';
import '../../viewmodels/module_assessment_view_model.dart';
import '../../viewmodels/module_view_model.dart';
import '../../widgets/assessment_result_view.dart';

class ModuleAssessmentScreen extends ConsumerWidget {
  final int moduleId;
  final String moduleName;

  const ModuleAssessmentScreen({
    super.key,
    required this.moduleId,
    required this.moduleName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = moduleAssessmentViewModelProvider(moduleId);

    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);
    final lang = ref.watch(languageProvider).languageId;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(AppStrings.of('assessment', lang)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.result != null) {
            return AssessmentResultView(
              result: state.result!,
              languageId: lang,
              onRetry: viewModel.retry,
              onDone: () {
                // The module list and dashboard both change when a module
                // completes, so they are refetched on the way out.
                ref.invalidate(moduleViewModelProvider);
                ref.invalidate(dashboardViewModelProvider);
                context.pop();
              },
            );
          }

          if (state.error != null && state.assessment == null) {
            return _Message(text: state.error!, onRetry: viewModel.load);
          }

          final questions = state.assessment?.questions ?? const [];

          if (questions.isEmpty) {
            return _Message(
              text: 'No assessment has been set for this module yet.',
              onRetry: viewModel.load,
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) => _QuestionCard(
                    question: questions[index],
                    index: index,
                    moduleId: moduleId,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: state.canSubmit && !state.isSubmitting
                        ? viewModel.submit
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            AppStrings.of('submit', lang),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuestionCard extends ConsumerWidget {
  final McqQuestion question;
  final int index;
  final int moduleId;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.moduleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = moduleAssessmentViewModelProvider(moduleId);
    final viewModel = ref.read(provider.notifier);

    ref.watch(provider);

    final image = mediaUrl(question.imageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q${index + 1}. ${question.questionTitle}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (question.allowsMultiple)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Select all that apply',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          if (image != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          for (final option in question.options)
            question.allowsMultiple
                ? CheckboxListTile(
                    title: Text(option.optionText),
                    value: viewModel.isSelected(
                      question.mcqId,
                      option.optionId,
                    ),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (_) => viewModel.select(
                      question,
                      option.optionId,
                    ),
                  )
                : RadioListTile<int>(
                    title: Text(option.optionText),
                    value: option.optionId,
                    contentPadding: EdgeInsets.zero,
                    // ignore: deprecated_member_use
                    groupValue: viewModel.isSelected(
                      question.mcqId,
                      option.optionId,
                    )
                        ? option.optionId
                        : null,
                    activeColor: AppColors.primary,
                    // ignore: deprecated_member_use
                    onChanged: (_) => viewModel.select(
                      question,
                      option.optionId,
                    ),
                  ),
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
