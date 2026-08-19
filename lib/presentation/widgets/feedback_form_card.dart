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
      decoration: AppGloss.card(r: AppGloss.radiusLg, shadow: AppGloss.lifted),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question title with a brand accent bar.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                margin: const EdgeInsets.only(top: 2, right: 12),
                height: 20,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradientRich,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Text(
                  widget.field.question,
                  style: AppText.h4,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (widget.field.isText)
            _AnswerBox(
              controller: _controller,
              onChanged: (value) => viewModel.setFormAnswer(
                widget.field.field,
                value.trim(),
              ),
            )
          else
            for (final option in widget.field.options)
              widget.field.isMultiple
                  ? _OptionTile(
                      label: option,
                      selected: viewModel.isFormOptionSelected(
                        widget.field.field,
                        option,
                      ),
                      multi: true,
                      onTap: () => viewModel.toggleFormOption(
                        widget.field.field,
                        option,
                      ),
                    )
                  : _OptionTile(
                      label: option,
                      selected:
                          viewModel.formValue(widget.field.field) == option,
                      multi: false,
                      onTap: () => viewModel.setFormAnswer(
                        widget.field.field,
                        option,
                      ),
                    ),
        ],
      ),
    );
  }
}

/// A rounded, tappable answer row with an animated plum selected state.
class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final bool multi;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.selected,
    required this.multi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: selected
                    ? [
                        AppColors.primary.withValues(alpha: 0.14),
                        AppColors.primary.withValues(alpha: 0.08),
                      ]
                    : const [Colors.white, Color(0xFFF6F1FA)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.hairline,
                width: selected ? 1.6 : 1,
              ),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                else
                  const BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                _Indicator(selected: selected, multi: multi),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w600,
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

/// Filled plum circle (single choice) or rounded square with a check
/// (multiple choice).
class _Indicator extends StatelessWidget {
  final bool selected;
  final bool multi;

  const _Indicator({required this.selected, required this.multi});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        shape: multi ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: multi ? BorderRadius.circular(6) : null,
        border: Border.all(
          color: selected ? AppColors.primary : Colors.grey.shade400,
          width: 1.6,
        ),
      ),
      child: selected
          ? (multi
              ? const Icon(Icons.check, size: 15, color: Colors.white)
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

/// Rounded text answer box for free-text questions.
class _AnswerBox extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;

  const _AnswerBox({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF6F1FA)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: 3,
        style: AppText.body,
        decoration: const InputDecoration(
          hintText: 'Type your answer',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
