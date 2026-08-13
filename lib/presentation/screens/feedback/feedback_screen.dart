import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/entities/feedback_question.dart';
import '../../viewmodels/feedback_view_model.dart';
import '../../viewmodels/language_view_model.dart';
import '../../viewmodels/login_view_model.dart';
import '../../widgets/feedback_form_card.dart';

/// Which half of the feedback is being shown.
///
/// [mood] runs straight after sign-in and asks only the two mood questions.
/// [full] is opened from the side navigation and holds the rest of the
/// trainee questionnaire.
enum FeedbackMode { mood, full }

class FeedbackScreen extends ConsumerWidget {
  final FeedbackMode mode;

  const FeedbackScreen({super.key, this.mode = FeedbackMode.full});

  bool get _isMood => mode == FeedbackMode.mood;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedbackViewModelProvider);
    final viewModel = ref.read(feedbackViewModelProvider.notifier);
    final lang = ref.watch(languageProvider).languageId;

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

        _leave(context);
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

    final items = _isMood ? state.questions : state.formFields;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _isMood
              ? (userName.isEmpty ? 'Welcome' : 'Welcome $userName')
              : AppStrings.of('feedback', lang),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !_isMood,
        actions: [
          TextButton(
            onPressed: () => _leave(context),
            child: Text(
              _isMood ? 'Skip' : 'Close',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? _Message(
                  text: state.error ??
                      'No questions are available right now.',
                  languageId: lang,
                  onRetry: viewModel.load,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Intro(isMood: _isMood),
                      const SizedBox(height: 20),
                      if (_isMood)
                        for (final question in state.questions)
                          _MoodCard(question: question)
                      else
                        for (final field in state.formFields)
                          FeedbackFormCard(field: field),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _canSubmit(state) && !state.isSubmitting
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
                            : Text(
                                AppStrings.of('submit', lang),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  bool _canSubmit(FeedbackState state) =>
      _isMood ? state.canSubmitMood : state.canSubmitForm;

  void _leave(BuildContext context) {
    if (_isMood) {
      context.go(AppRoutes.home);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }
}

class _Intro extends StatelessWidget {
  final bool isMood;

  const _Intro({required this.isMood});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEAEA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isMood
            ? "Hello and welcome!\n\nBefore we get started, let's get to know "
                "you a little better."
            : 'Your answers help us improve the training. Nothing here is '
                'compulsory — answer what you like.',
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }
}

class _MoodCard extends ConsumerWidget {
  final FeedbackQuestion question;

  const _MoodCard({required this.question});

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
          const SizedBox(height: 12),
          for (final option in question.options)
            question.allowsMultiple
                ? CheckboxListTile(
                    title: Text(option.optionName),
                    value: viewModel.isSelected(
                      question.questionId,
                      option.optionId,
                    ),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (_) => viewModel.toggleMultiple(
                      question.questionId,
                      option.optionId,
                    ),
                  )
                : RadioListTile<int>(
                    title: Text(option.optionName),
                    value: option.optionId,
                    contentPadding: EdgeInsets.zero,
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
