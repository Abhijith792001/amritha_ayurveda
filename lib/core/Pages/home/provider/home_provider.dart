import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../storage/app_storage.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AppStorage _storage = AppStorage();

  List<dynamic> _patients = [];
  List<dynamic> get patients => _patients;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchPatientList() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storage.getToken();
      if (token != null) {
        final response = await _apiService.getPatientList(token);
        if (response.statusCode == 200 && response.data['status'] == true) {
          _patients = response.data['patient'] ?? [];
        }
      }
    } catch (e) {
      debugPrint("Error fetching patients: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
