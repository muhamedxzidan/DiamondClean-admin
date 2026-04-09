import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  const AuthLocalDataSource(this._storage);

  static const _emailKey = 'auth_email';
  static const _passwordKey = 'auth_password';
  static const _rememberMeKey = 'auth_remember_me';

  Future<void> saveCredentials(String email, String password) async {
    await Future.wait([
      _storage.write(key: _emailKey, value: email),
      _storage.write(key: _passwordKey, value: password),
      _storage.write(key: _rememberMeKey, value: 'true'),
    ]);
  }

  Future<void> clearCredentials() async {
    await Future.wait([
      _storage.delete(key: _emailKey),
      _storage.delete(key: _passwordKey),
      _storage.delete(key: _rememberMeKey),
    ]);
  }

  Future<({String email, String password, bool rememberMe})>
      loadCredentials() async {
    final email = await _storage.read(key: _emailKey) ?? '';
    final password = await _storage.read(key: _passwordKey) ?? '';
    final rememberMe = await _storage.read(key: _rememberMeKey) == 'true';
    return (email: email, password: password, rememberMe: rememberMe);
  }
}
