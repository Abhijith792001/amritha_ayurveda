import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> saveUser({
    required String id,
    required String name,
    required String phone,
  }) async {
    await _storage.write(key: _userIdKey, value: id);
    await _storage.write(key: _userNameKey, value: name);
    await _storage.write(key: _userPhoneKey, value: phone);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  Future<String?> getUserPhone() async {
    return await _storage.read(key: _userPhoneKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _userPhoneKey);
  }

  Future<bool> hasToken() async {
    String? token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
