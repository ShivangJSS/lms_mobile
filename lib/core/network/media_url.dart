import 'api_constants.dart';

/// Builds a fetchable URL from the paths the LMS stores.
///
/// Values come back in three shapes:
///   "app/uploads/English/images/x.png"  -> legacy Laravel path
///   "uploads/module_icons/x.png"        -> current upload path
///   "x.jpeg"                            -> bare file name
///
/// All three are handed to the media endpoint as-is; the server searches the
/// storage folder and the API's own uploads folder, with and without the
/// "app/" prefix, and streams whatever it finds. A bare name is assumed to
/// sit in [folder].
String? mediaUrl(String? path, {String folder = ''}) {
  if (path == null) return null;

  final trimmed = path.trim();

  if (trimmed.isEmpty) return null;

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }

  var relative = trimmed.replaceAll('\\', '/').replaceFirst(RegExp(r'^/+'), '');

  // A bare file name carries no folder of its own, so the caller supplies it.
  if (folder.isNotEmpty && !relative.contains('/')) {
    relative = '$folder/$relative';
  }

  return '${ApiConstants.baseUrl}${ApiConstants.media}/$relative';
}
