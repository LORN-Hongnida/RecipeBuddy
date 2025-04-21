import 'package:flutter/material.dart';
import 'package:recipe_app/pages/welcomePage.dart';
import 'package:recipe_app/widget/backButton.dart';

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
          // Back Arrow Button
          const BackButtonOverlay(),
          // Top Text Elements
          Positioned(
            top: 80, // Adjust to avoid overlap with the arrow
            left: 30,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Continue Button at the Bottom
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 246, 211, 168),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 233, 133, 82)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}