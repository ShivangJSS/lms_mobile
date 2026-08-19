import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/glossy.dart';
import '../../domain/entities/feedback_question.dart';
import '../viewmodels/feedback_view_model.dart';

/// One question of the longer trainee questionnaire. Renders as radios,
/// checkboxes or a text box depending on the field type from the API.
class FeedbackFormCard extends ConsumerStatefulWidget {
  final FeedbackFormField field;

  const FeedbackFormCard({super.key, required this.field});

  @override
  ConsumerState<FeedbackFormCard> createState() => _FeedbackFormCardState();
}

class _FeedbackFormCardState extends ConsumerState<FeedbackFormCard> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();

    if (widget.field.isText) {
      _controller = TextEditingController(
        text: ref.read(feedbackViewModelProvider.notifier).formValue(
              widget.field.field,
            ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(feedbackViewModelProvider.notifier);

    // Watched so selections repaint.
    ref.watch(feedbackViewModelProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: AppGloss.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.field.question,
            style: AppText.h4,
          ),
          const SizedBox(height: AppSpacing.md),
          if (widget.field.isText)
            TextField(
              controller: _controller,
              maxLines: 3,
              style: AppText.body,
              decoration: const InputDecoration(
                hintText: 'Type your answer',
              ),
              onChanged: (value) => viewModel.setFormAnswer(
                widget.field.field,
                value.trim(),
              ),
            )
          else
            for (final option in widget.field.options)
              widget.field.isMultiple
                  ? CheckboxListTile(
                      title: Text(option),
                      value: viewModel.isFormOptionSelected(
                        widget.field.field,
                        option,
                      ),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (_) => viewModel.toggleFormOption(
                        widget.field.field,
                        option,
                      ),
                    )
                  : RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      contentPadding: EdgeInsets.zero,
                      // ignore: deprecated_member_use
                      groupValue: viewModel.formValue(widget.field.field),
                      activeColor: AppColors.primary,
                      // ignore: deprecated_member_use
                      onChanged: (_) => viewModel.setFormAnswer(
                        widget.field.field,
                        option,
                      ),
                    ),
        ],
      ),
    );
  }
}
