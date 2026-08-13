import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/entities/module_assessment.dart';
import '../../viewmodels/dashboard_view_model.dart';
import '../../viewmodels/language_view_model.dart';
import '../../viewmodels/module_assessment_view_model.dart';
import '../../viewmodels/module_view_model.dart';
import '../../widgets/assessment_result_view.dart';
import '../../widgets/questions/assessment_header.dart';
import '../../widgets/questions/choice_question_card.dart';
import '../../widgets/questions/drop_bucket_card.dart';
import '../../widgets/questions/match_making_card.dart';

/// One question per page: instructions, then each question in turn, then the
/// result.
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Women With Wheels'),
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
                // Module list and dashboard both change when a module
                // completes, so they are refetched on the way out.
                ref.invalidate(moduleViewModelProvider);
                ref.invalidate(dashboardViewModelProvider);
                context.pop();
              },
            );
          }

          if (state.error != null && state.assessment == null) {
            return _Message(
              text: state.error!,
              languageId: lang,
              onRetry: viewModel.load,
            );
          }

          if (state.questions.isEmpty) {
            return _Message(
              text: 'No assessment has been set for this module yet.',
              languageId: lang,
              onRetry: viewModel.load,
            );
          }

          if (state.onInstructions) {
            return _InstructionsPage(
              moduleName: moduleName,
              onStart: viewModel.next,
            );
          }

          final question = state.currentQuestion!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AssessmentHeader.forQuestion(question),
                      const SizedBox(height: 22),
                      _card(question, state.pageIndex + 1, lang),
                    ],
                  ),
                ),
              ),
              AssessmentNavBar(
                onPrevious: state.pageIndex > 0 ? viewModel.previous : null,
                onNext: state.onLastQuestion
                    ? (state.canSubmit ? viewModel.submit : null)
                    : (state.canAdvance ? viewModel.next : null),
                nextLabel: state.onLastQuestion ? 'Submit' : 'Next',
                isBusy: state.isSubmitting,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(AssessmentQuestionItem question, int number, int lang) {
    if (question.isDropBucket) {
      return DropBucketCard(
        question: question,
        number: number,
        moduleId: moduleId,
        languageId: lang,
      );
    }

    if (question.isMatchMaking) {
      return MatchMakingCard(
        question: question,
        number: number,
        moduleId: moduleId,
        languageId: lang,
      );
    }

    return ChoiceQuestionCard(
      question: question,
      number: number,
      moduleId: moduleId,
      languageId: lang,
    );
  }
}

class _InstructionsPage extends StatelessWidget {
  final String moduleName;
  final VoidCallback onStart;

  const _InstructionsPage({required this.moduleName, required this.onStart});

  static const _points = [
    'Read each question carefully.',
    'Includes MCQ, Yes/No, Match, and Drop types. Answer all questions to '
        'finish the test.',
    'No negative marking — attempt all.',
    'Tap Next & then Submit to save your responses.',
    'View your score and correct answers after submission.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssessmentHeader(title: moduleName),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assessment Instructions',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (final point in _points)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('•  ',
                                  style: TextStyle(fontSize: 17)),
                              Expanded(
                                child: Text(
                                  point,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        AssessmentNavBar(nextLabel: 'Next', onNext: onStart),
      ],
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
