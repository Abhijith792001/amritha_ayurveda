import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_bg.jpg'),
          ),
        ),
        child: Center(
          child: Column(children: [Image.asset('assets/images/logo.png')]),
        ),
      ),
    );
  }
}
