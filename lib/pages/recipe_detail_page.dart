import 'package:flutter/material.dart';

class RecipeDetailPage extends StatelessWidget {
  final Map<String, String> recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Breakfast',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.orange),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.orange),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                recipe['image']!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              recipe['title'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 8),

            // Time & Rating
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.deepOrange),
                const SizedBox(width: 6),
                Text(
                  recipe['time'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.star, size: 18, color: Colors.deepOrange),
                const SizedBox(width: 6),
                Text(
                  recipe['rating'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Details
            const Text(
              "Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Fluffy pancakes served with silky whipped cream, a classic breakfast indulgence perfect for a leisurely morning treat.",
              style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
            ),

            const SizedBox(height: 24),

            // Ingredients
            const Text(
              "Ingredients",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            ..._buildIngredientsList(),

            const SizedBox(height: 24),

            // Easy Steps
            const Text(
              "Instructions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const StepList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIngredientsList() {
    List<String> ingredients = [
      "1 cup all-purpose flour",
      "2 tablespoons granulated sugar",
      "1 teaspoon baking powder",
      "1/2 teaspoon baking soda",
      "1/4 teaspoon salt",
      "1 cup buttermilk (or regular milk)",
      "1 large egg",
      "2 tablespoons unsalted butter, melted",
      "Additional butter or oil for cooking",
    ];

    return ingredients.map((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.orange, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class StepList extends StatelessWidget {
  const StepList({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      '1. In a large bowl, whisk together the flour, sugar, baking powder, baking soda, and salt.',
      '2. In another bowl, whisk the buttermilk, egg, and melted butter together.',
      '3. Pour the wet ingredients into the dry ingredients and stir until just combined.',
      '4. Heat a non-stick pan over medium heat and grease lightly with butter or oil.',
      '5. Pour 1/4 cup of batter for each pancake and cook until bubbles form, then flip.',
      '6. Serve the pancakes warm with whipped cream and syrup!',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: steps.map((step) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            step,
            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
          ),
        );
      }).toList(),
    );
  }
}
