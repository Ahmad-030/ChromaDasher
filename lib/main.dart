
import 'package:flutter/material.dart';

import 'SplashScreen.dart';


void main() {
  runApp(const ThemeSwapRunnerApp());
}

class ThemeSwapRunnerApp extends StatelessWidget {
  const ThemeSwapRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theme Swap Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}