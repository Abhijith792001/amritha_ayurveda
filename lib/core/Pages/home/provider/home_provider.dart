import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../storage/app_storage.dart';
import '../../../models/patient_model.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AppStorage _storage = AppStorage();

  List<Patient> _patients = [];
  List<Patient> get patients => _patients;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Patient> get filteredPatients {
    if (_searchQuery.isEmpty) {
      return _patients;
    }
    final query = _searchQuery.toLowerCase();
    return _patients.where((patient) {
      final nameMatch = (patient.name ?? "").toLowerCase().contains(query);
      final treatmentMatch = patient.patientDetails.any(
        (detail) => (detail.treatmentName ?? "").toLowerCase().contains(query),
      );
      return nameMatch || treatmentMatch;
    }).toList();
  }

  Future<void> fetchPatientList() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storage.getToken();
      if (token != null) {
        final response = await _apiService.getPatientList(token);
        debugPrint("Patient List Response Status: ${response.statusCode}");
        debugPrint(
          "Patient List Data Status: ${response.data['status']} (${response.data['status'].runtimeType})",
        );

        if (response.statusCode == 200 &&
            response.data['status'].toString() == 'true') {
          final List<dynamic> patientList = response.data['patient'] ?? [];

          List<Patient> parsedPatients = [];
          for (var i = 0; i < patientList.length; i++) {
            try {
              parsedPatients.add(Patient.fromJson(patientList[i]));
            } catch (e) {
              debugPrint("Error parsing patient at index $i: $e");
              debugPrint("Patient data: ${patientList[i]}");
            }
          }

          _patients = parsedPatients;
          debugPrint("Loaded ${_patients.length} patients");
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
