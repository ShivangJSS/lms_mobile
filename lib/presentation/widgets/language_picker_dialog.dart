import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/glossy.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/feedback_view_model.dart';
import '../viewmodels/language_view_model.dart';
import '../viewmodels/module_view_model.dart';

/// Opens the language chooser and reloads the language-dependent screens if
/// the selection changed.
Future<void> showLanguagePicker(BuildContext context, WidgetRef ref) async {
  // Fetch the list before showing anything, so the sheet opens populated.
  await ref.read(languageProvider.notifier).loadLanguages();

  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (_) => const _LanguagePickerDialog(),
  );
}

class _LanguagePickerDialog extends ConsumerWidget {
  const _LanguagePickerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(languageProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: AppGloss.card(r: AppGloss.radiusLg, shadow: AppGloss.lifted),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: AppGloss.panel(
                      color: AppColors.tintedPanel,
                      r: AppGloss.radiusSm,
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Text('Change Language', style: AppText.h4),
                ],
              ),
            ),
            if (state.languages.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Languages could not be loaded. Please check your '
                  'connection and try again.',
                  textAlign: TextAlign.center,
                  style: AppText.muted,
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    for (final language in state.languages)
                      _LanguageTile(
                        name: language.languageName,
                        selected: language.languageId == state.languageId,
                        onTap: () async {
                          await _apply(ref, language.languageId);

                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _apply(WidgetRef ref, int languageId) async {
    if (ref.read(languageProvider).languageId == languageId) return;

    await ref.read(languageProvider.notifier).setLanguage(languageId);

    // These view models read the language when they are built, so discarding
    // them is what makes the new language take effect.
    ref.invalidate(moduleViewModelProvider);
    ref.invalidate(dashboardViewModelProvider);
    ref.invalidate(feedbackViewModelProvider);
  }
}

class _LanguageTile extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppGloss.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppGloss.radius),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: selected
                ? BoxDecoration(
                    gradient: AppColors.brandGradientRich,
                    borderRadius: BorderRadius.circular(AppGloss.radius),
                    boxShadow: AppGloss.buttonGlow,
                  )
                : AppGloss.panel(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: AppText.label.copyWith(
                      color: selected
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? Colors.white : AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
