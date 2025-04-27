import 'package:flutter/material.dart';
import '../widget/custom_bottom_nav.dart';
import 'home_page.dart';
import 'ingredient_input_page.dart';
import 'profile_page.dart';
import 'category_food_page.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widget/notification_widget.dart';
import '../widget/search_widget.dart';

Future<List<Map<String, String>>> fetchFoodItems(String category) async {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('categories/$category');

  try {
    final DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      final value = snapshot.value;

      if (value is List) {
        // If it's a List
        return value.whereType<Map>().map((item) {
          return item.map((key, value) => MapEntry(key.toString(), value.toString()));
        }).toList();
      } else if (value is Map) {
        // If it's a Map
        return Map<String, dynamic>.from(value).values.map((item) {
          return Map<String, String>.from(item);
        }).toList();
      } else {
        return [];
      }
    } else {
      return [];
    }
  } catch (e) {
    debugPrint('Error fetching food items for $category: $e');
    return [];
  }
}


class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  int _selectedIndex = 2;
  bool _isLoading = false;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => IngredientInputPage()));
        break;
      case 2:
        break; // Current page
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
    }
  }

  final List<Map<String, String>> categories = [
    {'title': 'seafood', 'image': 'assets/images/seafood.jpg', 'displayTitle': 'Seafood'},
    {'title': 'lunch', 'image': 'assets/images/lunch.jpg', 'displayTitle': 'Lunch'},
    {'title': 'breakfast', 'image': 'assets/images/breakfast.jpg', 'displayTitle': 'Breakfast'},
    {'title': 'dinner', 'image': 'assets/images/dinner.jpg', 'displayTitle': 'Dinner'},
    {'title': 'vegan', 'image': 'assets/images/vegan.jpg', 'displayTitle': 'Vegan'},
    {'title': 'desserts', 'image': 'assets/images/dessert.jpg', 'displayTitle': 'Desserts'},
    {'title': 'drinks', 'image': 'assets/images/drink.jpg', 'displayTitle': 'Drinks'},
    {'title': 'fastfood', 'image': 'assets/images/fastfood.jpg', 'displayTitle': 'Fastfood'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Categories',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        leading: const SizedBox(),
        actions: [
          const NotificationWidget(),
          const SearchWidget(),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: GridView.builder(
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 3 / 2.6,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    final foodItems = await fetchFoodItems(category['title']!);
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryFoodPage(
                          categoryTitle: category['displayTitle']!, // Use displayTitle for UI
                          foodItems: foodItems,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[100],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.asset(
                              category['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              category['displayTitle']!, // Use displayTitle for UI
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}