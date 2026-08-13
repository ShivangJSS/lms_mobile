import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/colors.dart';
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

    return AlertDialog(
      title: const Text('Change Language'),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      content: SizedBox(
        width: double.maxFinite,
        child: state.languages.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Languages could not be loaded. Please check your '
                  'connection and try again.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final language in state.languages)
                    RadioListTile<int>(
                      title: Text(language.languageName),
                      value: language.languageId,
                      // ignore: deprecated_member_use
                      groupValue: state.languageId,
                      activeColor: AppColors.primary,
                      // ignore: deprecated_member_use
                      onChanged: (value) async {
                        if (value == null) return;

                        await _apply(ref, value);

                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
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
