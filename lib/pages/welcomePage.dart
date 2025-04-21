import 'package:flutter/material.dart';
import 'package:recipe_app/pages/login.dart';
import 'package:recipe_app/widget/roundedButton.dart';
import 'package:recipe_app/widget/imageCard.dart'; // Import the new widget
import 'package:recipe_app/widget/backButton.dart';
import 'package:recipe_app/pages/login.dart';

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
                          imageUrl: 'https://bosskitchen.com/wp-content/uploads/2021/08/korean-fried-chicken-recipe.jpg',
                          onTap: () {
                            print('Dish 1 Tapped');
                            // Handle tap
                          },
                        ),
                        ImageCard(
                          imageUrl: 'https://tse2.mm.bing.net/th/id/OIP.kG7PLRbcPtrCsDpfPUyEGwHaI0?w=1200&h=1429&rs=1&pid=ImgDetMain',
                          onTap: () {
                            print('Waffles Tapped');
                            // Handle tap
                          },
                        ),
                        ImageCard(
                          imageUrl: 'https://tse4.mm.bing.net/th/id/OIP.wVGElzaepMnY_Pfj29QJgwHaLH?rs=1&pid=ImgDetMain',
                          onTap: () {
                            print('Wrap Tapped');
                            // Handle tap
                          },
                        ),
                        ImageCard(
                          imageUrl: 'https://tse2.mm.bing.net/th/id/OIP.RwhooZyHtn_haZn-sIsciAHaE8?w=1620&h=1080&rs=1&pid=ImgDetMain',
                          onTap: () {
                            print('Lasagna Tapped');
                            // Handle tap
                          },
                        ),
                        ImageCard(
                          imageUrl: 'https://lovefoodfeed.com/wp-content/uploads/2023/01/Macarons-px-1200-01-1-1024x1024.jpg',
                          onTap: () {
                            print('Macarons Tapped');
                            // Handle tap
                          },
                        ),
                        ImageCard(
                          imageUrl: 'https://cocktailflavors.com/wp-content/uploads/2024/03/pisco-mojito-cocktail-recipe_001-683x1024.png',
                          onTap: () {
                            print('Mojito Tapped');
                            // Handle tap
                          },
                        ),
                      ],
                    ),
                  )
                ),
                const SizedBox(height: 20),
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
                  text: 'I\'m New',
                  onPressed: () {
                    print('I\'m New pressed');
                    // Handle "I'm New" action
                    // Navigator.push(...)
                  },
                ),
                const SizedBox(height: 10),
                RoundedButton(
                  text: 'I\'ve Been Here',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                ),
              ],
            ),
          ),
          // Back Button Overlay
          const BackButtonOverlay(
            padding: EdgeInsets.only(top: 15, left: 10), // Adjust padding for precise positioning
          ),
        ],
      ),
    );
  }
}