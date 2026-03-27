import 'package:flutter/material.dart';

import 'About.dart' show AboutScreen;
import 'GameScreen.dart';
import 'HIghScore.dart';
import 'MainMenu.dart';
import 'Privacy_policy.dart';
import 'SplashScreen.dart';

void main() {
  runApp(const ThemeSwapRunnerApp());
}

class ThemeSwapRunnerApp extends StatelessWidget {
  const ThemeSwapRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashScreen(),
      routes: {
        '/menu':      (_) => const MainMenuScreen(),
        '/game':      (_) => const GameScreen(),
        '/highscore': (_) => const HighscoreScreen(),
        '/about':     (_) => const AboutScreen(),
        '/privacy':   (_) => const PrivacyPolicyScreen(),
      },
    );
  }
}