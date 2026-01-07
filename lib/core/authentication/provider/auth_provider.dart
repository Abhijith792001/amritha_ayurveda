import 'package:amritha_ayurveda/core/authentication/view/login_page.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../storage/app_storage.dart';
import '../../utils/snackbar_service.dart';
import '../../utils/navigation_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AppStorage _storage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _token;
  String? get token => _token;

  String? _userName;
  String? get userName => _userName;

  String? _userId;
  String? get userId => _userId;

  String? _userPhone;
  String? get userPhone => _userPhone;

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

        final userDetails = response.data['user_details'];
        if (userDetails != null) {
          final String userId = userDetails['id'].toString();
          final String userName = userDetails['name'] ?? '';
          final String userPhone = userDetails['phone'] ?? '';
          await _storage.saveUser(id: userId, name: userName, phone: userPhone);
        }

        _setLoading(false);
        SnackbarService.showSnackBar("Login Successful!");
        return true;
      } else {
        final message = response.data['message'] ?? "Login Failed";
        SnackbarService.showSnackBar(message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      SnackbarService.showSnackBar("An error occurred during login");
      _setLoading(false);
      return false;
    }
  }

  Future<void> loadToken() async {
    _token = await _storage.getToken();
    _userName = await _storage.getUserName();
    _userId = await _storage.getUserId();
    _userPhone = await _storage.getUserPhone();
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.deleteToken();
    _token = null;
    _userName = null;
    _userId = null;
    _userPhone = null;
    notifyListeners();
    NavigationService.pushAndRemoveUntil(const LoginPage());
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
