import 'package:flutter/material.dart';
import 'package:recipe_app/pages/home_page.dart';
import 'package:recipe_app/pages/login_page.dart';
import 'package:recipe_app/widget/rounded_button.dart';
import 'package:recipe_app/widget/image_card.dart'; // Import the new widget
import 'package:recipe_app/widget/back_button.dart';
import 'package:recipe_app/pages/profile_page.dart';
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(padding: const EdgeInsets.only(top: 50.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2,
                      children: [
                        ImageCard(
                          imageUrl: 'assets/images/korean-fried-chicken.jpg',
                        ),
                        ImageCard(
                          imageUrl: 'assets/images/waffle.jpg',
                        ),
                        ImageCard(
                          imageUrl: 'assets/images/wraps.jpg',
                        ),
                        ImageCard(
                          imageUrl: 'assets/images/lasagna.jpg',
                        ),
                        ImageCard(
                          imageUrl: 'assets/images/Macarons.jpg',
                        ),
                        ImageCard(
                          imageUrl: 'assets/images/mojito.webp',
                        ),
                      ],
                    ),
                  )
                ),
                const SizedBox(height: 15),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Scan your ingredients, get recipe recommendations, and start cooking with ease.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                RoundedButton(
                  text: 'Quest Mode',
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
                const SizedBox(height: 10),
                RoundedButton(
                  text: 'Log In/Sign Up',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                ),
                const SizedBox(height: 15,)
              ],
            ),
          ),
          // Back Button Overlay
          const BackButtonOverlay(),
        ],
      ),
    );
  }
}