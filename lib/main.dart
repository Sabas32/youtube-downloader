import 'package:flutter/material.dart';
import 'package:youtube_downloder_final/screens/download.dart';
import 'package:youtube_downloder_final/screens/splash_screen.dart';

import 'screens/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/download': (context) => const Downloads(),
        '/home': (context) => const Home(),
      },
      debugShowCheckedModeBanner: false,
      title: 'SWIFT TUBE',
      home: const SplashScreen(),
    );
  }
}
