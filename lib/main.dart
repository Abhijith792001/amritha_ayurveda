import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/home_provider.dart';
import 'core/views/home_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => HomeProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amritha Ayurveda',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff006837)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
