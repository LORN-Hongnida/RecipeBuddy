import 'package:flutter/material.dart';
import 'pages/get_inspired.dart';
import 'pages/splash_screen.dart';


void main() =>runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanCook',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: SplashScreen(),
    );
  }
}