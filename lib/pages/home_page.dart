import 'package:flutter/material.dart';
import '../services/spoonacular_service.dart';
import '../models/recipe.dart';
import 'profile_page.dart';
import 'category_page.dart';
import 'ingredient_input_page.dart';
import '../widget/custom_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpoonacularService _spoonacularService = SpoonacularService();
  List<Recipe> _popularRecipes = [];
  List<Recipe> _yourRecipes = [];
  List<Recipe> _recentlyAdded = [];
  bool _isLoading = true;
  String _error = '';
  int _selectedIndex = 0; // To track the currently selected item

  @override
  void initState() {
    super.initState();
    _loadHomePageData();
  }

  Future<void> _loadHomePageData({String category = ''}) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final popular = await _spoonacularService.getPopularRecipes(number: 5);
      setState(() {
        _popularRecipes = popular;
        _yourRecipes = popular; // Modify this if you have different data for user recipes
        _recentlyAdded = popular; // Modify this as well if needed
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load recipes: $e';
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => IngredientInputPage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CategoryPage()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfilePage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Make body extend under the floating navigation bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: IconButton(
            icon: const Icon(Icons.menu, color: Colors.grey),
            onPressed: () {
              print('Menu Tapped');
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
              onPressed: () {
                print('Notifications Tapped');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: () {
                print('Search Tapped');
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : SingleChildScrollView(
        padding: const EdgeInsets.only(
            left: 20, top: 20, right: 20, bottom: 80), // Adjust bottom padding for the floating bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hi! Dianne',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'What are you cooking today',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: [
                  'Breakfast',
                  'Lunch',
                  'Dinner',
                  'Vegan',
                  'Dessert',
                  'Snacks'
                ].length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = [
                    'Breakfast',
                    'Lunch',
                    'Dinner',
                    'Vegan',
                    'Dessert',
                    'Snacks'
                  ][index];
                  return ElevatedButton(
                    onPressed: () {
                      print('$category Tapped');
                      _loadHomePageData(category: category); // Pass the selected category to filter
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(category),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Trending Recipe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _popularRecipes.isNotEmpty
                ? _buildTrendingRecipeCard(_popularRecipes.first)
                : const Text('No trending recipes available.'),
            const SizedBox(height: 30),
            const Text(
              'Your Recipes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: _yourRecipes.isNotEmpty
                  ? ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _yourRecipes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                  return _buildSmallRecipeCard(_yourRecipes[index]);
                },
              )
                  : const Text('No recipes in your collection.'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Recently Added',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: _recentlyAdded.isNotEmpty
                  ? ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _recentlyAdded.length,
                separatorBuilder: (context, index) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                  return _buildSmallRecipeCard(_recentlyAdded[index]);
                },
              )
                  : const Text('No recently added recipes.'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildTrendingRecipeCard(Recipe recipe) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              recipe.imageUrl ??
                  'https://via.placeholder.com/300/E8EAF6/000000?Text=No+Image',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 120,
                width: double.infinity,
                child: Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  recipe.description ?? 'No description available.',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: Colors.orange),
                        const SizedBox(width: 3),
                        Text('${recipe.cookingTime ?? "?"} min', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rate_outlined, size: 14, color: Colors.orange),
                        const SizedBox(width: 3),
                        Text('${recipe.rating?.toStringAsFixed(1) ?? "?"}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallRecipeCard(Recipe recipe) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              recipe.imageUrl ??
                  'https://via.placeholder.com/120/E8EAF6/000000?Text=No+Image',
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 80,
                width: double.infinity,
                child: Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rate_outlined, size: 10, color: Colors.orange),
                    const SizedBox(width: 2),
                    Text('${recipe.rating?.toStringAsFixed(1) ?? "?"}', style: const TextStyle(fontSize: 10)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 10, color: Colors.orange),
                    const SizedBox(width: 2),
                    Text('${recipe.cookingTime ?? "?"} min', style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}