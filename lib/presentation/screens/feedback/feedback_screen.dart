import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/entities/feedback_question.dart';
import '../../viewmodels/feedback_view_model.dart';
import '../../viewmodels/login_view_model.dart';
import '../../widgets/feedback_form_card.dart';

class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedbackViewModelProvider);
    final viewModel = ref.read(feedbackViewModelProvider.notifier);

    final userName =
        ref.watch(loginViewModelProvider).user?.participantName ?? '';

    ref.listen<FeedbackState>(feedbackViewModelProvider, (previous, next) {
      if (next.isSubmitted && previous?.isSubmitted != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        context.go(AppRoutes.home);
      }

      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(userName.isEmpty ? 'Feedback' : 'Welcome $userName'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.questions.isEmpty
              ? _EmptyOrError(
                  message: state.error ??
                      'No feedback questions are available right now.',
                  onRetry: viewModel.load,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBEAEA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "Hello and welcome!\n\nWe're excited to have you "
                          "here. Before we get started, let's get to know you "
                          "a little better.",
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (final question in state.questions)
                        _QuestionCard(question: question),
                      if (state.formFields.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'Tell us more',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Optional — it helps us improve the training.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        for (final field in state.formFields)
                          FeedbackFormCard(field: field),
                      ],
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: state.canSubmit && !state.isSubmitting
                            ? viewModel.submit
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.grey.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                            : const Text(
                                'Submit Feedback',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _QuestionCard extends ConsumerWidget {
  final FeedbackQuestion question;

  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(feedbackViewModelProvider.notifier);

    // Watched so the tiles rebuild when a selection changes.
    ref.watch(feedbackViewModelProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEAEA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.questionName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (question.questionDescription != null &&
              question.questionDescription!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              question.questionDescription!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          for (final option in question.options)
            question.allowsMultiple
                ? CheckboxListTile(
                    title: Text(option.optionName),
                    value: viewModel.isSelected(
                      question.questionId,
                      option.optionId,
                    ),
                    activeColor: AppColors.primary,
                    onChanged: (_) => viewModel.toggleMultiple(
                      question.questionId,
                      option.optionId,
                    ),
                  )
                : RadioListTile<int>(
                    title: Text(option.optionName),
                    value: option.optionId,
                    // ignore: deprecated_member_use
                    groupValue: viewModel.isSelected(
                      question.questionId,
                      option.optionId,
                    )
                        ? option.optionId
                        : null,
                    activeColor: AppColors.primary,
                    // ignore: deprecated_member_use
                    onChanged: (_) => viewModel.selectSingle(
                      question.questionId,
                      option.optionId,
                    ),
                  ),
        ],
      ),
    );
  }
}

class _EmptyOrError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _EmptyOrError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
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
