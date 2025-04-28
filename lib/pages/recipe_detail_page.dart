import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeDetailPage extends StatefulWidget {
  final String categoryName;
  final String recipeId; // recipeId is unique within category

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
  bool isFavorite = false; // Track if recipe is favorited

  @override
  void initState() {
    super.initState();
    debugPrint('RecipeDetailPage: categoryName=${widget.categoryName}, recipeId=${widget.recipeId}');
    fetchRecipeDetails();
    checkFavoriteStatus();
  }

  // Check if the recipe is in the user's favorites
  Future<void> checkFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favoriteId = '${widget.categoryName}_${widget.recipeId}';
      final ref = FirebaseDatabase.instance.ref('users/${user.uid}/favorites/$favoriteId');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        setState(() {
          isFavorite = true;
        });
      }
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add to favorites')),
      );
      return;
    }

    final favoriteId = '${widget.categoryName}_${widget.recipeId}';
    final ref = FirebaseDatabase.instance.ref('users/${user.uid}/favorites/$favoriteId');
    try {
      if (isFavorite) {
        // Remove from favorites
        await ref.remove();
        setState(() {
          isFavorite = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites')),
        );
      } else {
        // Add to favorites
        await ref.set({
          'categoryName': widget.categoryName,
          'recipeId': widget.recipeId,
          'favoriteId': favoriteId,
          'title': recipeData?['title'] ?? '',
          'image': recipeData?['image'] ?? '',
          'time': recipeData?['time'] ?? '',
          'likes': recipeData?['likes'] ?? 0,
          'desc': recipeData?['desc'] ?? '',
        });
        debugPrint('Added favorite: $favoriteId, category=${widget.categoryName}, recipeId=${widget.recipeId}');
        setState(() {
          isFavorite = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites')),
        );
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating favorites')),
      );
    }
  }

  Future<void> fetchRecipeDetails() async {
    try {
      final ref = FirebaseDatabase.instance.ref('categories/${widget.categoryName}/${widget.recipeId}');
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
        debugPrint('No recipe found: ${widget.categoryName}/${widget.categoryName}/${widget.recipeId}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe not found')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading recipe')),
      );
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Color.fromARGB(255, 255, 108, 67)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          recipeData?['title'] ?? 'Recipe',
          style: const TextStyle(color: Color.fromARGB(255, 255, 108, 67), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Color.fromARGB(255, 255, 108, 67),
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 255, 108, 67)))
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
                color: Color.fromARGB(255, 255, 108, 67),
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
                color: Color.fromARGB(255, 255, 108, 67),
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
                color: Color.fromARGB(255, 255, 108, 67),
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
                    const Icon(Icons.check_circle_outline, color: Color.fromARGB(255, 255, 108, 67), size: 18),
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
                color: Color.fromARGB(255, 255, 108, 67),
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
                        color: Color.fromARGB(255, 255, 108, 67).withOpacity(0.5),
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