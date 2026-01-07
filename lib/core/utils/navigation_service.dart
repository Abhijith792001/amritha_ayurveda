import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<dynamic>? navigateTo(Widget page) {
    return navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static Future<dynamic>? pushAndRemoveUntil(Widget page) {
    return navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  static void goBack() {
    return navigatorKey.currentState?.pop();
  }
}
