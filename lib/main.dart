import 'package:arabot/Pages/MainPage.dart';
import 'package:flutter/material.dart';

import 'Intro/IntroPage.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AraBot',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home:  SplashScreen(), // Set MainMenu as the home widget
    );
  }
}
