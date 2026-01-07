import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../utils/snackbar_service.dart';
import '../utils/navigation_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint("Connectivity init error: $e");
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // connectivity_plus returns a list
    final bool online = !results.contains(ConnectivityResult.none);

    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();

      if (!_isOnline) {
        _showNoInternetDialog();
      } else {
        SnackbarService.showSnackBar("Internet Connected", isSuccess: true);
      }
    }
  }

  void _showNoInternetDialog() {
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          title: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.red, size: 24.sp),
              SizedBox(width: 10.w),
              Text("No Internet", style: TextStyle(fontSize: 18.sp)),
            ],
          ),
          content: Text(
            "Please turn on your internet connection to continue using the app.",
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final result = await _connectivity.checkConnectivity();
                final bool stillOffline = result.contains(
                  ConnectivityResult.none,
                );
                if (!stillOffline) {
                  if (context.mounted) Navigator.pop(context);
                } else {
                  SnackbarService.showSnackBar(
                    "Still offline. Please check your connection.",
                    isError: true,
                  );
                }
              },
              child: Text(
                "Retry",
                style: TextStyle(
                  color: const Color(0xff006837),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
