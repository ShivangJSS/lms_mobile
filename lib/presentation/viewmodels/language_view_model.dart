import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/providers.dart';
import '../../core/services/language_storage.dart';
import '../../domain/entities/learning_module.dart';

/// Language id read from storage before the app starts, so every view model
/// can pick it up synchronously. Overridden in main().
final initialLanguageIdProvider = Provider<int>(
  (ref) => LanguageStorage.defaultLanguageId,
);

class LanguageState {
  final int languageId;
  final List<AppLanguage> languages;
  final bool isLoading;

  const LanguageState({
    required this.languageId,
    this.languages = const [],
    this.isLoading = false,
  });

  String get currentName {
    for (final language in languages) {
      if (language.languageId == languageId) return language.languageName;
    }
    return '';
  }

  LanguageState copyWith({
    int? languageId,
    List<AppLanguage>? languages,
    bool? isLoading,
  }) {
    return LanguageState(
      languageId: languageId ?? this.languageId,
      languages: languages ?? this.languages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LanguageController extends StateNotifier<LanguageState> {
  final Ref ref;

  LanguageController(this.ref, int initialLanguageId)
      : super(LanguageState(languageId: initialLanguageId));

  /// Loaded lazily — only needed when the picker is opened.
  Future<void> loadLanguages() async {
    if (state.languages.isNotEmpty || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final languages =
          await ref.read(moduleRepositoryProvider).getLanguages();

      state = state.copyWith(
        languages: languages,
        isLoading: false,
      );
    } catch (_) {
      // The picker falls back to whatever is already known.
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setLanguage(int languageId) async {
    if (state.languageId == languageId) return;

    await LanguageStorage.save(languageId);

    state = state.copyWith(languageId: languageId);
  }
}

final languageProvider =
    StateNotifierProvider<LanguageController, LanguageState>(
  (ref) => LanguageController(
    ref,
    ref.read(initialLanguageIdProvider),
  ),
);
