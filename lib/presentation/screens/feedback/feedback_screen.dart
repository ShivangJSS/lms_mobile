import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/glossy.dart';
import '../../../core/widgets/primary_button.dart';
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
      backgroundColor: AppColors.background,
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageWash),
        child: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? _Message(
                  text: state.error ??
                      'No questions are available right now.',
                  languageId: lang,
                  onRetry: viewModel.load,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Intro(isMood: _isMood),
                      const SizedBox(height: AppSpacing.xl),
                      if (_isMood)
                        for (final question in state.questions)
                          _MoodCard(question: question)
                      else
                        for (final field in state.formFields)
                          FeedbackFormCard(field: field),
                      const SizedBox(height: AppSpacing.sm),
                      PrimaryButton(
                        text: AppStrings.of('submit', lang),
                        isLoading: state.isSubmitting,
                        onPressed: _canSubmit(state) && !state.isSubmitting
                            ? viewModel.submit
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
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
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: AppGloss.card(),
      child: Text(
        isMood
            ? "Hello and welcome!\n\nBefore we get started, let's get to know "
                "you a little better."
            : 'Your answers help us improve the training. Nothing here is '
                'compulsory — answer what you like.',
        style: AppText.body,
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
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: AppGloss.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.questionName,
            style: AppText.h4,
          ),
          if (question.questionDescription != null &&
              question.questionDescription!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(question.questionDescription!, style: AppText.muted),
          ],
          const SizedBox(height: AppSpacing.md),
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
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppText.muted,
            ),
            const SizedBox(height: AppSpacing.lg),
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
