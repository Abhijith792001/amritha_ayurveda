import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../storage/app_storage.dart';

class RegisterProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AppStorage _storage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> registerPatient(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final token = await _storage.getToken();
      if (token == null) return false;

      final response = await _apiService.updatePatient(data, token);

      _setLoading(false);
      return response.statusCode == 200 && response.data['status'] == true;
    } catch (e) {
      debugPrint("Register Error: $e");
      _setLoading(false);
      return false;
    }
  }
}
