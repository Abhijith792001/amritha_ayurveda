import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../storage/app_storage.dart';
import '../../../services/pdf_service.dart';
import '../../../utils/snackbar_service.dart';

class RegisterProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AppStorage _storage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<dynamic> _branches = [];
  List<dynamic> get branches => _branches;

  List<dynamic> _treatments = [];
  List<dynamic> get treatments => _treatments;

  Future<void> fetchBranches() async {
    try {
      final token = await _storage.getToken();
      if (token != null) {
        final response = await _apiService.getBranchList(token);
        if (response.statusCode == 200 && response.data['status'] == true) {
          _branches = response.data['branches'] ?? [];
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error fetching branches: $e");
    }
  }

  Future<void> fetchTreatments() async {
    try {
      final token = await _storage.getToken();
      if (token != null) {
        final response = await _apiService.getTreatmentList(token);
        if (response.statusCode == 200 && response.data['status'] == true) {
          _treatments = response.data['treatments'] ?? [];
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error fetching treatments: $e");
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Performs a POST request to register or update a patient details.
  /// API: PatientUpdate [POST]
  Future<(bool, Map<String, dynamic>?)> registerPatient({
    required String name,
    required String phone,
    required String address,
    required String totalAmount,
    required String discountAmount,
    required String advanceAmount,
    required String balanceAmount,
    required String payment,
    required String branch,
    required String executive,
    required DateTime treatmentDate,
    required String hour,
    required String minute,
    required List<Map<String, dynamic>> selectedTreatments,
  }) async {
    _setLoading(true);
    try {
      final token = await _storage.getToken();
      if (token == null) return (false, null);

      // 1. Format Time (12h AM/PM)
      final h24 = int.tryParse(hour) ?? 10;
      final period = h24 >= 12 ? "PM" : "AM";
      final h12 = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
      final timeStr = "${h12.toString().padLeft(2, '0')}:$minute $period";

      // 2. Format Date (dd/mm/yyyy)
      final dateStr =
          "${treatmentDate.day.toString().padLeft(2, '0')}/${treatmentDate.month.toString().padLeft(2, '0')}/${treatmentDate.year}";

      // 3. Format Treatment Lists
      final maleIds = selectedTreatments.map((e) => e['male']).join(',');
      final femaleIds = selectedTreatments.map((e) => e['female']).join(',');
      final treatmentIds = selectedTreatments.map((e) => e['id']).join(',');

      final data = {
        'id': '',
        'name': name,
        'phone': phone,
        'address': address,
        'total_amount': totalAmount,
        'discount_amount': discountAmount,
        'advance_amount': advanceAmount,
        'balance_amount': balanceAmount,
        'payment': payment,
        'branch': branch,
        'excecutive': executive,
        'date_nd_time': '$dateStr-$timeStr',
        'male': maleIds,
        'female': femaleIds,
        'treatments': treatmentIds,
      };

      debugPrint("Registration Payload: $data");
      final response = await _apiService.updatePatient(data, token);
      debugPrint("Registration Response status: ${response.statusCode}");
      debugPrint("Registration Response data: ${response.data}");

      _setLoading(false);
      final success =
          response.statusCode == 200 && response.data['status'] == true;
      return (success, success ? data : null);
    } catch (e) {
      debugPrint("Register Error: $e");
      _setLoading(false);
      return (false, null);
    }
  }

  Future<bool> registerAndGeneratePdf({
    required String name,
    required String phone,
    required String address,
    required String totalAmount,
    required String discountAmount,
    required String advanceAmount,
    required String balanceAmount,
    required String payment,
    required String? branchId,
    required String executive,
    required DateTime? treatmentDate,
    required String hour,
    required String minute,
    required List<Map<String, dynamic>> selectedTreatments,
  }) async {
    if (branchId == null) {
      SnackbarService.showSnackBar("Please select a branch", isError: true);
      return false;
    }
    if (selectedTreatments.isEmpty) {
      SnackbarService.showSnackBar(
        "Please add at least one treatment",
        isError: true,
      );
      return false;
    }
    if (treatmentDate == null) {
      SnackbarService.showSnackBar(
        "Please select a treatment date",
        isError: true,
      );
      return false;
    }

    // 2. Perform API Call
    final (success, data) = await registerPatient(
      name: name,
      phone: phone,
      address: address,
      totalAmount: totalAmount,
      discountAmount: discountAmount,
      advanceAmount: advanceAmount,
      balanceAmount: balanceAmount,
      payment: payment,
      branch: branchId,
      executive: executive,
      treatmentDate: treatmentDate,
      hour: hour,
      minute: minute,
      selectedTreatments: selectedTreatments,
    );

    // 3. Handle Result
    if (success && data != null) {
      SnackbarService.showSnackBar("Registered Successfully", isSuccess: true);
      // 4. Generate PDF
      await PdfService.generateRegistrationPdf(data, selectedTreatments);
      return true;
    } else {
      SnackbarService.showSnackBar("Registration Failed", isError: true);
      return false;
    }
  }
}
