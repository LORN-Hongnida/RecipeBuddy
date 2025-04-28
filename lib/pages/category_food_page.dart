import 'package:flutter/material.dart';
import 'recipe_detail_page.dart';
import '../widget/notification_widget.dart';
import '../widget/search_widget.dart';

class CategoryFoodPage extends StatelessWidget {
  final String categoryTitle;
  final List<Map<String, dynamic>> foodItems;

  const CategoryFoodPage({
    super.key,
    required this.categoryTitle,
    required this.foodItems,
  });

  // Helper to safely convert List<Object?> to List<Map<String, String>>
  static List<Map<String, String>> convertFoodItems(List<Object?> data) {
    return data.map((item) {
      if (item is Map) {
        return item.map((key, value) =>
            MapEntry(key.toString(), value.toString())
        );
      } else {
        return <String, String>{}; // Return empty map if wrong type
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color.fromARGB(255, 255, 108, 67)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          categoryTitle,
          style: const TextStyle(
            color: Color.fromARGB(255, 255, 108, 67),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          const NotificationWidget(),
          const SearchWidget(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: foodItems.isEmpty
            ? const Center(child: Text('No items found for this category'))
            : GridView.builder(
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
                print(categoryTitle);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailPage(
                      categoryName: categoryTitle.toLowerCase(), // Pass the category title
                      recipeId: item['id'] ?? '',     // Pass the recipe ID (or title if you don't have real IDs)
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.shade100.withOpacity(0.4),
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
                        item['image'] ?? '',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.error));
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] ?? 'No Title',
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
                              item['desc'] ?? '',
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
                                    Text(item['likes'] ?? '0'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Color.fromARGB(255, 255, 108, 67)),
                                    const SizedBox(width: 4),
                                    Text(item['time'] ?? '0 min'),
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
    );
  }
}
