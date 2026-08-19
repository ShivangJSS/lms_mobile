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
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );

        _leave(context);
      }

      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });

    final items = _isMood ? state.questions : state.formFields;

    // The header is drawn behind the body (extendBodyBehindAppBar), so the
    // scroll content must start below the status bar + app bar to avoid being
    // hidden under it.
    final headerInset = MediaQuery.of(context).padding.top + kToolbarHeight;

    final title = _isMood
        ? (userName.isEmpty ? 'Welcome' : 'Welcome $userName')
        : AppStrings.of('feedback', lang);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !_isMood,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        flexibleSpace: Container(
          decoration: AppGloss.header(r: 28),
          child: Stack(
            children: [
              // Faint decorative bubbles bleeding off the header edges.
              Positioned(top: -46, right: -30, child: _bubble(150)),
              Positioned(bottom: -50, left: -40, child: _bubble(130)),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: _GlassPill(
              label: _isMood ? 'Skip' : 'Close',
              onTap: () => _leave(context),
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
                : SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        headerInset + AppSpacing.lg,
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
                            trailingIcon: Icons.check_rounded,
                            onPressed:
                                _canSubmit(state) && !state.isSubmitting
                                    ? viewModel.submit
                                    : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  static Widget _bubble(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.06),
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

/// A frosted "glass" pill used for the Skip / Close action on the header.
class _GlassPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GlassPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: AppGloss.glass(r: 30, opacity: 0.18),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  final bool isMood;

  const _Intro({required this.isMood});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: AppGloss.card(r: AppGloss.radiusLg, shadow: AppGloss.lifted),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A raised, top-lit brand chip holding a friendly icon.
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradientRich,
              borderRadius: BorderRadius.circular(AppGloss.radiusSm),
              boxShadow: AppGloss.buttonGlow,
            ),
            child: Icon(
              isMood
                  ? Icons.emoji_emotions_rounded
                  : Icons.chat_bubble_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMood ? 'Hello and welcome!' : 'A few quick questions',
                  style: AppText.h3.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  isMood
                      ? "Before we get started, let's get to know you a "
                          'little better.'
                      : 'Your answers help us improve the training. Nothing '
                          'here is compulsory — answer what you like.',
                  style: AppText.muted,
                ),
              ],
            ),
          ),
        ],
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
      decoration:
          AppGloss.card(r: AppGloss.radiusLg, shadow: AppGloss.lifted),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading accent bar for a clear, hierarchical heading.
              Container(
                width: 4,
                height: 22,
                margin: const EdgeInsets.only(top: 2, right: AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradientRich,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Text(
                  question.questionName,
                  style: AppText.h4,
                ),
              ),
            ],
          ),
          if (question.questionDescription != null &&
              question.questionDescription!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.lg),
              child: Text(question.questionDescription!, style: AppText.muted),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          for (final option in question.options)
            _OptionTile(
              label: option.optionName,
              isMultiple: question.allowsMultiple,
              selected: viewModel.isSelected(
                question.questionId,
                option.optionId,
              ),
              onTap: question.allowsMultiple
                  ? () => viewModel.toggleMultiple(
                        question.questionId,
                        option.optionId,
                      )
                  : () => viewModel.selectSingle(
                        question.questionId,
                        option.optionId,
                      ),
            ),
        ],
      ),
    );
  }
}

/// A glossy, tappable option row with a clear selected state in brand plum.
/// Renders a circular indicator for single-choice and a rounded square for
/// multiple-choice, matching radio / checkbox semantics.
class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isMultiple;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.selected,
    required this.isMultiple,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md + 2,
            ),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF3E7F7), Color(0xFFE7D6EF)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Color(0xFFF7F1FB)],
                    ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.hairline,
                width: selected ? 1.6 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                _Indicator(selected: selected, isMultiple: isMultiple),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppText.body.copyWith(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? AppColors.primaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The filled brand indicator inside an [_OptionTile].
class _Indicator extends StatelessWidget {
  final bool selected;
  final bool isMultiple;

  const _Indicator({required this.selected, required this.isMultiple});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      height: 24,
      width: 24,
      decoration: BoxDecoration(
        gradient: selected ? AppColors.buttonGloss : null,
        color: selected ? null : Colors.white,
        shape: isMultiple ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isMultiple ? BorderRadius.circular(7) : null,
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xFFC7B6CE),
          width: 1.6,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: selected
          ? (isMultiple
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : Center(
                  child: Container(
                    height: 8,
                    width: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ))
          : null,
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
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration:
              AppGloss.card(r: AppGloss.radiusLg, shadow: AppGloss.lifted),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                text,
                textAlign: TextAlign.center,
                style: AppText.muted,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: Text(AppStrings.of('retry', languageId)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
