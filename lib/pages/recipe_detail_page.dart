import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RecipeDetailPage extends StatefulWidget {
  final String categoryName;
  final String recipeId; // recipeId could be title, or an actual ID

  const RecipeDetailPage({
    super.key,
    required this.categoryName,
    required this.recipeId,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  Map<String, dynamic>? recipeData;
  List<String> ingredients = [];
  List<String> steps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    try {
      final ref = FirebaseDatabase.instance.ref('categories/${widget.categoryName}/${widget.recipeId}'); // Fetch by ID
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        recipeData = data;
        ingredients = List<String>.from(data['ingredients'] ?? []);
        steps = List<String>.from(data['steps'] ?? []);

        debugPrint('Fetched recipe: $recipeData');

        setState(() {
          isLoading = false;
        });
      } else {
        debugPrint('No recipe found with ID: ${widget.recipeId}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching recipe: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          recipeData?['title'] ?? 'Recipe',
          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.share, color: Colors.orange), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border, color: Colors.orange), onPressed: () {}),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : recipeData == null
          ? const Center(child: Text("Recipe not found.", style: TextStyle(color: Colors.black54)))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: (recipeData?['image'] ?? '').toString().startsWith('http')
                  ? Image.network(
                recipeData?['image'] ?? '',
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              )
                  : recipeData?['image'] != null && recipeData?['image'] != ''
                  ? Image.asset(
                recipeData?['image'],
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : const SizedBox(
                height: 220,
                width: double.infinity,
                child: Center(child: Icon(Icons.image_not_supported, size: 50)),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              recipeData?['title'] ?? '',
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
                  recipeData?['time'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.star, size: 18, color: Colors.deepOrange),
                const SizedBox(width: 6),
                Text(
                  (recipeData?['likes'] ?? '').toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Details Section
            const Text(
              "Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recipeData?['desc'] ?? 'No description available.',
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 16),
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
            if (ingredients.isEmpty)
              const Text("No ingredients available.", style: TextStyle(fontSize: 15, color: Colors.black54))
            else
              ...ingredients.map((item) => Padding(
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
              )),

            const SizedBox(height: 24),

            // Instructions
            const Text(
              "Instructions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            if (steps.isEmpty)
              const Text("No instructions available.", style: TextStyle(fontSize: 15, color: Colors.black54))
            else
              ...steps.asMap().entries.map((entry) {
                int index = entry.key;
                String step = entry.value;
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
                    "${index + 1}. $step",
                    style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                  ),
                );
              }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
