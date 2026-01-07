import 'package:amritha_ayurveda/core/Pages/splash/view/splash_screen_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'core/Pages/home/provider/home_provider.dart';
import 'core/Pages/splash/provider/splash_screen_provider.dart';
import 'core/authentication/provider/auth_provider.dart';
import 'core/Pages/register/provider/register_provider.dart';
import 'core/utils/snackbar_service.dart';
import 'core/utils/navigation_service.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/widgets/connectivity_wrapper.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SplashScreenProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          scaffoldMessengerKey: SnackbarService.messengerKey,
          debugShowCheckedModeBanner: false,
          title: 'Amritha Ayurveda',
          theme: ThemeData(
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff006837),
            ),
            useMaterial3: true,
          ),
          builder: (context, child) {
            return ConnectivityWrapper(child: child ?? const SizedBox.shrink());
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
