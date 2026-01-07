import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../storage/app_storage.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AppStorage _storage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _token;
  String? get token => _token;

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      final response = await _apiService.login(username, password);
      debugPrint("Login Response Data: ${response.data}");
      debugPrint("Login Status Code: ${response.statusCode}");

      final dynamic status = response.data['status'];
      debugPrint("Login Status Value: $status (${status.runtimeType})");

      if (response.statusCode == 200 && status.toString() == 'true') {
        _token = response.data['token'];
        await _storage.saveToken(_token!);
        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<void> loadToken() async {
    _token = await _storage.getToken();
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.deleteToken();
    _token = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
