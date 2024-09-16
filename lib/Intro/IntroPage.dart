import 'package:flutter/material.dart';
import 'dart:async';
import '../Pages/MainPage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeInAnimation;
  Animation<double>? _scaleAnimation;
  Animation<double>? _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // Adjust total duration
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeIn,
      ),
    )..addListener(() {
      setState(() {});
    });

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.elasticOut,
      ),
    )..addListener(() {
      setState(() {});
    });

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut), // Fade out in the last 20% of the duration
      ),
    )..addListener(() {
      setState(() {});
    });

    _animationController!.forward();

    // Start the transition to the main page after the entire animation including fade out
    Timer(Duration(milliseconds: 3500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeOutAnimation!,
        child: Container(
          decoration:const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 146, 65, 65), Color.fromARGB(255, 69, 30, 30)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation!,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/image/logo.png', // Replace with your logo asset path
                    width: 200, // Adjust the width as needed
                    height: 200, // Adjust the height as needed
                  ),
                  const SizedBox(height: 20),
                  // const CircularProgressIndicator(
                  //   valueColor: AlwaysStoppedAnimation<Color>(Colors.yellowAccent),
                 // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
