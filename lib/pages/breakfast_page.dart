import 'package:flutter/material.dart';
import 'recipe_detail_page.dart'; // import the detail page

class BreakfastPage extends StatelessWidget {
  const BreakfastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(// Soft light background
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Breakfast',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.orange),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.orange),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  CategoryTab(title: 'Breakfast', selected: true),
                  CategoryTab(title: 'Lunch'),
                  CategoryTab(title: 'Dinner'),
                  CategoryTab(title: 'Vegan'),
                  CategoryTab(title: 'Drinks'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          // Grid of food cards
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: foodItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.70,
                ),
                itemBuilder: (context, index) {
                  final item = foodItems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailPage(recipe: item),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.shade100.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            child: Image.asset(
                              item['image']!,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['subtitle']!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.favorite, size: 16, color: Colors.pinkAccent),
                                          const SizedBox(width: 4),
                                          Text(item['rating']!),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 16, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Text(item['time']!),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }
}

class CategoryTab extends StatelessWidget {
  final String title;
  final bool selected;

  const CategoryTab({super.key, required this.title, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(title),
        backgroundColor: selected ? Colors.orange : Colors.grey[200],
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}

// Dummy food items list
final List<Map<String, String>> foodItems = [
  {
    'title': 'Pancake & Cream',
    'subtitle': 'Muffin with Canadian bacon',
    'rating': '4',
    'image': 'assets/images/pancake_cream.jpg',
    'time': '15min',
  },
  {
    'title': 'French Toast',
    'subtitle': 'Delicious slices of bread',
    'rating': '5',
    'image': 'assets/images/french_toast.jpg',
    'time': '20min',
  },
  {
    'title': 'Oatmeal and Nut',
    'subtitle': 'Wholesome blend for breakfast',
    'rating': '4',
    'image': 'assets/images/oatmeal_nuts.jpg',
    'time': '35min',
  },
  {
    'title': 'Still Life Potato',
    'subtitle': 'Earthy, textured, rustic charm',
    'rating': '4',
    'image': 'assets/images/still_potato.jpg',
    'time': '30min',
  },
  {
    'title': 'Fruit Bowl',
    'subtitle': 'Strawberry, Blueberry & Mint',
    'rating': '5',
    'image': 'assets/images/fruit_bowl.jpg',
    'time': '10min',
  },
  {
    'title': 'Bruschetta Toast',
    'subtitle': 'Fresh tomato and basil toast',
    'rating': '5',
    'image': 'assets/images/bruschetta_toast.jpg',
    'time': '12min',
  },
];
