import 'package:flutter/material.dart';
import '../authentication/view/login_page.dart';

class SplashScreenProvider extends ChangeNotifier {
  void initSplashScreen(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }
}
