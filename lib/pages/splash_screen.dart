import 'package:flutter/material.dart';
import 'package:recipe_app/pages/get_inspired.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 1.0;

  @override
  void initState() {
    super.initState();
    // Start the fade-out and navigation after a delay
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        opacity = 0.0;
      });
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GetInspiredPage()), // Replace HomePage with your main page
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 108, 67),
      body: Center(
        child: AnimatedOpacity(
          opacity: opacity,
          duration: Duration(seconds: 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png', // Replace with your splash image path
                width: 250,
                height: 250,
              ),
              // SizedBox(height: 20),
              Text(
                'ScanCook', // Or any other text you want
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.white,

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}