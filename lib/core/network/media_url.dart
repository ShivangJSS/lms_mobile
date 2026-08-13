import 'api_constants.dart';

/// Builds a fetchable URL from the paths the LMS stores.
///
/// Values come back in three shapes:
///   "app/uploads/English/images/x.png"  -> legacy Laravel path
///   "uploads/module_icons/x.png"        -> current upload path
///   "x.jpeg"                            -> bare file name
/// The server mounts everything under /uploads, so the leading "app/" is
/// dropped and a bare name is assumed to sit in the given [folder].
String? mediaUrl(String? path, {String folder = ''}) {
  if (path == null) return null;

  final trimmed = path.trim();

  if (trimmed.isEmpty) return null;

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }

  var relative = trimmed.replaceFirst(RegExp(r'^app/'), '');

  if (!relative.startsWith('uploads/')) {
    final prefix = folder.isEmpty ? '' : '$folder/';
    relative = 'uploads/$prefix$relative';
  }
  return '${ApiConstants.baseUrl}/$relative';
}
