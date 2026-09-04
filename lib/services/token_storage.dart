import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _tokenKey = 'lesi_access_token';
  static const _emailKey = 'lesi_user_email';

  final FlutterSecureStorage _storage;

  Future<void> saveSession({
    required String accessToken,
    required String email,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _emailKey, value: email);
  }

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<String?> readEmail() => _storage.read(key: _emailKey);

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
  }
}
