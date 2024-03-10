import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    toNextScren(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        body: Center(
          child: const Image(
            image: AssetImage('assets/images/youtube downloader-black.png'),
            width: 200,
          ).animate().fadeOut(
                duration: const Duration(seconds: 1),
                delay: const Duration(seconds: 2),
              ),
        ),
      ),
    );
  }
}

Future<void> toNextScren(context) async {
  await Future.delayed(const Duration(seconds: 4));
  Navigator.pushReplacementNamed(context, '/home');
}
