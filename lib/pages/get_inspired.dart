import 'package:flutter/material.dart';
import 'package:recipe_app/pages/onboarding.dart'; // Import the OnboardingPage
import 'package:recipe_app/pages/welcomePage.dart';
import 'package:recipe_app/widget/roundedButton.dart';

class GetInspiredPage extends StatelessWidget {
  const GetInspiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/inspired.jpg',
            fit: BoxFit.cover,
          ),
          // Top Text Elements
          Positioned(
            top: 100,
            left: 30,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Get Inspired',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Scan your ingredients and discover delicious recipes!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Continue Button at the Bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: RoundedButton(
                text: 'Continue',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OnboardingPage(
                        imagePath: 'assets/images/onboard.jpg',
                        title: 'Enhance Your Cooking',
                        description: 'Learn new techniques and tips from expert chefs.',
                        buttonText: 'Explore',
                        onButtonPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => WelcomePage()));
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}