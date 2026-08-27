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

/// Puts an absolute URL the server built for itself back onto
/// [ApiConstants.baseUrl].
///
/// `/pptx/info` composes its slide URLs with FastAPI's `url_for`, which uses
/// the host and scheme uvicorn itself sees. Behind a reverse proxy that is the
/// internal address — `http://192.168.3.176:8068/...` — which a phone cannot
/// route to, and which Android blocks anyway because the host is not listed
/// for cleartext. Only the origin is swapped; the path and the raw query are
/// the server's own and are passed through untouched.
///
/// The proper fix is `--proxy-headers` on uvicorn so `url_for` emits the
/// public address. This keeps the app working until that lands, and is a no-op
/// once it does.
String sanitizeMediaUrl(String url) {
  final trimmed = url.trim();

  if (trimmed.isEmpty) return trimmed;

  final target = Uri.tryParse(trimmed);

  if (target == null) return trimmed;

  final base = Uri.parse(ApiConstants.baseUrl);

  // A relative path only needs the base in front of it.
  if (!target.hasScheme) {
    final relative = trimmed.replaceFirst(RegExp(r'^/+'), '');

    return '${base.origin}/$relative';
  }

  // Already pointing at the configured API: leave it exactly as it is.
  if (target.scheme == base.scheme && target.host == base.host) {
    return trimmed;
  }

  return '${base.origin}${target.path}'
      '${target.hasQuery ? '?${target.query}' : ''}';
}
