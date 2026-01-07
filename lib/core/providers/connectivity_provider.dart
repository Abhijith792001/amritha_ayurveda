import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

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
      debugPrint("Connectivity init error : $e");
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    debugPrint("Connectivity Changed: $results");

    final bool offline =
        results.contains(ConnectivityResult.none) || results.isEmpty;
    final bool online = !offline;

    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
      debugPrint("AppState: ${_isOnline ? "ONLINE" : "OFFLINE"}");
    }
  }

  Future<void> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }
}
