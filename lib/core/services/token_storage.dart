import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage();

  static const _accessTokenKey = "access_token";
  static const _refreshTokenKey = "refresh_token";

  /// The access token kept in memory as well as in the keystore.
  ///
  /// Reading the keystore is asynchronous, but the media endpoints now need a
  /// bearer token on widgets that build synchronously — Image.network and the
  /// video player both want their headers at build time and cannot await. The
  /// cache is filled on save and on every read, so by the time any media is on
  /// screen the token is already here.
  static String? _cachedAccessToken;

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cachedAccessToken = accessToken;

    await _storage.write(
      key: _accessTokenKey,
      value: accessToken,
    );

    await _storage.write(
      key: _refreshTokenKey,
      value: refreshToken,
    );
  }

  static Future<String?> getAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);

    _cachedAccessToken = token;

    return token;
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  /// The headers a media request needs, or an empty map when signed out.
  ///
  /// Empty rather than null so callers can hand it straight to Image.network
  /// without a branch.
  static Map<String, String> get mediaHeaders {
    final token = _cachedAccessToken;

    if (token == null || token.isEmpty) return const {};

    return {'Authorization': 'Bearer $token'};
  }

  static Future<void> clear() async {
    _cachedAccessToken = null;

    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
