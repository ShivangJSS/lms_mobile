import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the content language between launches. Plain preferences, not
/// secure storage — this is a display setting, not a credential.
class LanguageStorage {
  LanguageStorage._();

  static const _key = "language_id";
  static const int defaultLanguageId = 1;

  static Future<int> get() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_key) ?? defaultLanguageId;
  }

  static Future<void> save(int languageId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_key, languageId);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }
}
