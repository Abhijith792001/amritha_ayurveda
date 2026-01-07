import 'package:flutter/material.dart';
import '../authentication/view/login_page.dart';
import '../storage/app_storage.dart';
import '../views/home_page.dart';

class SplashScreenProvider extends ChangeNotifier {
  final AppStorage _storage = AppStorage();

  Future<void> initSplashScreen(BuildContext context) async {
    final token = await _storage.getToken();

    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }
}
